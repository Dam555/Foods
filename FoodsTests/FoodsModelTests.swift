//
//  FoodsModelTests.swift
//  FoodsTests
//
//  Created by Damjan on 17.08.2022.
//

import Combine
@testable import Foods
import FoodsCore
import XCTest

class FoodsModelTests: XCTestCase {

    var subscriptions = Set<AnyCancellable>()

    override func tearDown() {
        subscriptions.removeAll()
        super.tearDown()
    }

    func testSearchMinLengthNoFoods() {
        let model = FoodsModel(
            apiGetFoods: { _ in
                Just([Food(id: 1, name: "BBQ Chicken Pizza")])
                    .setFailureType(to: ApiError.self)
                    .eraseToAnyPublisher()
            },
            searchDebounceDuration: 0.01
        )

        let foodsExpectation = expectation(description: "")
        var foodsEmptyCount = 0

        model.$foods
            .dropFirst()
            .sink { foods in
                if foods.isEmpty {
                    foodsEmptyCount += 1
                    if foodsEmptyCount == 2 {
                        foodsExpectation.fulfill()
                    }
                } else {
                    XCTFail("Foods should be empty")
                }
            }
            .store(in: &subscriptions)

        model.search = "a"

        let delayExpectation = expectation(description: "")
        delayExpectation.isInverted = true

        // Wait for at least `searchDebounceDuration`.
        wait(for: [delayExpectation], timeout: 0.1)

        model.search = "ab"

        waitForExpectations(timeout: 0.25)

        XCTAssertEqual(foodsEmptyCount, 2)
    }

    func testSearchFoods() {
        let food = Food(id: 1, name: "BBQ Chicken Pizza")
        var foodSearch = ""

        let model = FoodsModel(
            apiGetFoods: { search in
                foodSearch = search
                return Just([food])
                    .setFailureType(to: ApiError.self)
                    .eraseToAnyPublisher()
            },
            searchDebounceDuration: 0.01
        )

        let foodsExpectation = expectation(description: "")

        XCTAssertTrue(model.foods.isEmpty)

        model.$foods
            .dropFirst()
            .sink { foods in
                XCTAssertEqual(foods, [food])
                foodsExpectation.fulfill()
            }
            .store(in: &subscriptions)

        model.search = "pizza"

        waitForExpectations(timeout: 0.25)

        XCTAssertEqual(foodSearch, model.search)
        XCTAssertEqual(model.foods, [food])
    }

    func testSearchFoodsLoadingIndicator() {
        let food = Food(id: 1, name: "BBQ Chicken Pizza")
        var foodSearch = ""

        let model = FoodsModel(
            apiGetFoods: { search in
                foodSearch = search
                return Just([food])
                    .delay(for: 0.5, scheduler: DispatchQueue.main)
                    .setFailureType(to: ApiError.self)
                    .eraseToAnyPublisher()
            },
            searchDebounceDuration: 0.01,
            loadingIndicatorDelay: 0.3,
            loadingIndicatorMinDuration: 0.5
        )

        let foodsExpectation = expectation(description: "")

        XCTAssertTrue(model.foods.isEmpty)
        XCTAssertFalse(model.isLoadingIndicatorVisible)

        var loadingIndicatorVisibility = [Bool]()
        model.$isLoadingIndicatorVisible
            .dropFirst()
            .sink { isVisible in
                loadingIndicatorVisibility.append(isVisible)
            }
            .store(in: &subscriptions)

        model.$foods
            .dropFirst()
            .sink { foods in
                XCTAssertEqual(foods, [food])
                foodsExpectation.fulfill()
            }
            .store(in: &subscriptions)

        model.search = "pizza"

        waitForExpectations(timeout: 1.5)

        XCTAssertEqual(foodSearch, model.search)
        XCTAssertEqual(model.foods, [food])
        XCTAssertEqual(loadingIndicatorVisibility, [true, false] )
    }
}
