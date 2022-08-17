//
//  FoodsApp.swift
//  Foods
//
//  Created by Damjan on 15.08.2022.
//

import Combine
import FoodsCore
import SwiftUI

@main
struct FoodsApp: App {

    var body: some Scene {
        WindowGroup {
            if UIApplication.isRunningUnitTests {
                EmptyView()
            } else {
                FoodsView(model: makeFoodsModel())
                    .flow()
            }
        }
    }
}

private extension FoodsApp {

    func makeFoodsModel() -> FoodsModel {
        FoodsModel(
            apiGetFoods: { search in
                do {
                    return ApiClient().execute(try GetFoodsEndpoint(kv: search))
                } catch {
                    return Fail(outputType: [Food].self, failure: ApiError(error))
                        .eraseToAnyPublisher()
                }
            }
        )
    }
}
