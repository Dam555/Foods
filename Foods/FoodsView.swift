//
//  FoodsView.swift
//  Foods
//
//  Created by Damjan on 15.08.2022.
//

import Combine
import FoodsCore
import SwiftUI

struct FoodsView: View {

    @StateObject var model: FoodsModel

    private let layout = Layout()

    var isAlertPresented: Binding<Bool> {
        Binding<Bool>(
            get: {
                switch model.presentedAlert {
                case .none: return false
                default: return true
                }
            },
            set: { isPresented in
                guard !isPresented else { return }
                model.presentedAlert = .none
            }
        )
    }

    var body: some View {
        VStack(spacing: layout.foodsTop) {
            TextField(Localized.searchFoods, text: $model.search)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .padding([.leading, .trailing], layout.searchLeftRight)
            if model.isLoadingIndicatorVisible {
                Spacer()
                LoadingProgressView()
                Spacer()
            } else {
                List {
                    ForEach(model.foods) { food in
                        Button {
                            model.presentedAlert = .message(food.name)
                        } label: {
                            Text(food.name)
                        }
                    }
                }
                .listStyle(.plain)
                Spacer()
            }
        }
        .animation(.easeInOut(duration: layout.animationDuration), value: model.isLoadingIndicatorVisible)
        .navigationTitle(Localized.foodsTitle)
        .navigationBarTitleDisplayMode(.inline)
        .padding(.top, layout.searchTop)
        .alert(isPresented: isAlertPresented) {
            switch model.presentedAlert {
            case .message(let text):
                return Alert(title: Text(Localized.foodsTitle), message: Text(text), dismissButton: .cancel(Text(Localized.ok)))
            default:
                return Alert(title: Text(""))
            }
        }
    }
}

private extension FoodsView {

    struct Layout {
        let searchTop: CGFloat = 16
        let searchLeftRight: CGFloat = 16
        let foodsTop: CGFloat = 16
        let animationDuration: TimeInterval = 0.25
    }
}

struct FoodsView_Previews: PreviewProvider {

    static func makeModel() -> FoodsModel {
        let model = FoodsModel(
            apiGetFoods: { _ in
                Just([
                    Food(id: 1, name: "BBQ Chicken Pizza"),
                    Food(id: 2, name: "Alice Springs Chicken"),
                    Food(id: 3, name: "Chicken Alfredo"),
                ])
                .setFailureType(to: ApiError.self)
                .eraseToAnyPublisher()
            }
        )
        model.search = "123"
        return model
    }

    static var previews: some View {
        FoodsView(model: makeModel())
    }
}
