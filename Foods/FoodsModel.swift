//
//  FoodsModel.swift
//  Foods
//
//  Created by Damjan on 16.08.2022.
//

import Combine
import FoodsCore
import Foundation

class FoodsModel: ObservableObject {

    enum PresentedAlert {
        case none
        case message(String)
    }

    // Minimum number of characters in a search box to start searching for foods
    static let searchMinLength = 3

    // After user has stopped typing into search box, time interval to wait before food search is started
    static let searchDebounceDuration: TimeInterval = 0.5

    // After food search is started, time interval to wait before showing loading indicator
    static let loadingIndicatorDelay: TimeInterval = 0.5

    // After loading indicator is shown, time interval to wait before it can be hidden
    static let loadingIndicatorMinDuration: TimeInterval = 0.7

    let apiGetFoods: (String) -> AnyPublisher<[Food], ApiError>
    let searchDebounceDuration: TimeInterval
    let loadingIndicatorDelay: TimeInterval
    let loadingIndicatorMinDuration: TimeInterval
    var subscriptions = Set<AnyCancellable>()

    @Published var search = ""
    @Published var isLoadingIndicatorVisible = false
    @Published var foods = [Food]()
    @Published var presentedAlert = PresentedAlert.none

    @Published private var isLoading = false
    @Published private var canShowFoods = true

    init(apiGetFoods: @escaping (String) -> AnyPublisher<[Food], ApiError>,
         searchDebounceDuration: TimeInterval = FoodsModel.searchDebounceDuration,
         loadingIndicatorDelay: TimeInterval = FoodsModel.loadingIndicatorDelay,
         loadingIndicatorMinDuration: TimeInterval = FoodsModel.loadingIndicatorMinDuration) {
        self.apiGetFoods = apiGetFoods
        self.searchDebounceDuration = searchDebounceDuration
        self.loadingIndicatorDelay = loadingIndicatorDelay
        self.loadingIndicatorMinDuration = loadingIndicatorMinDuration

        // After foods start loading, wait for `loadingIndicatorDelay` seconds
        // before showing loading indicator if loading is still in progress
        $isLoading
            .filter { isLoading in
                isLoading
            }
            .debounce(for: .seconds(loadingIndicatorDelay), scheduler: DispatchQueue.main)
            .sink { [weak self] _ in
                guard let self = self, self.isLoading, !self.isLoadingIndicatorVisible else { return }
                self.isLoadingIndicatorVisible = true
            }
            .store(in: &subscriptions)

        // Hide loading indicator when food loading is not in progress anymore
        $isLoading
            .filter { isLoading in
                !isLoading
            }
            .sink { [weak self] _ in
                self?.isLoadingIndicatorVisible = false
            }
            .store(in: &subscriptions)

        // After loading indicator is shown, make sure it stays visible for at least
        // `loadingIndicatorMinDuration` seconds before it can be hidden and
        // foods can be shown if they were loaded.
        $isLoadingIndicatorVisible
            .filter { isLoadingVisible in
                isLoadingVisible
            }
            .handleEvents(receiveOutput: { [weak self] _ in
                self?.canShowFoods = false
            })
            .delay(for: .seconds(loadingIndicatorMinDuration), scheduler: DispatchQueue.main)
            .sink { [weak self] _ in
                self?.canShowFoods = true
            }
            .store(in: &subscriptions)

        $search
            .debounce(for: .seconds(self.searchDebounceDuration), scheduler: DispatchQueue.main)
            .handleEvents(receiveOutput: { [weak self] search in
                if search.count < Self.searchMinLength {
                    self?.foods = []
                    self?.isLoading = false
                }
            })
            .filter { search in
                search.count >= Self.searchMinLength
            }
            .handleEvents(receiveOutput: { [weak self] _ in
                self?.isLoading = true
            })
            .flatMap { [weak self] search -> AnyPublisher<(String, [Food]), Never> in
                guard let self = self else {
                    return Just((search, [Food]()))
                        .eraseToAnyPublisher()
                }
                return self.apiGetFoods(search)
                    .receive(on: DispatchQueue.main)
                    .handleEvents(receiveCompletion: { completion in
                        if case .failure(let error) = completion {
                            print("Error: \(error)")
                        }
                    })
                    .replaceError(with: [])
                    .map { foods in
                        (search, foods)
                    }
                    .eraseToAnyPublisher()
            }
            .combineLatest($canShowFoods)
            .sink { [weak self] (searchAndFoods, canShowFoods) in
                // Make sure foods that pertain to current query in search box are shown
                guard let self = self, searchAndFoods.0 == self.search, canShowFoods else { return }
                self.foods = searchAndFoods.1
                self.isLoading = false
            }
            .store(in: &subscriptions)
    }
}
