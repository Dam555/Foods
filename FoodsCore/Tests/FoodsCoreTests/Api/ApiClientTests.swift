//
//  ApiClientTests.swift
//  
//
//  Created by Damjan on 17.08.2022.
//

import Combine
@testable import FoodsCore
import XCTest

class ApiClientTests: XCTestCase {

    var subscriptions = Set<AnyCancellable>()

    override func tearDown() {
        subscriptions.removeAll()
        super.tearDown()
    }

    func testExecuteReadableApiEndpoint() {
        let appConfiguration = MockAppConfiguration()
        let mockEntity = Entity(name: "Name")
        let apiClient = ApiClient(
            dataPublisher: { request in
                self.mockDataPublisher(url: request.url, entity: mockEntity, statusCode: 200)
            },
            appConfiguration: appConfiguration
        )

        let valueExpectation = expectation(description: "")
        let completionExpectation = expectation(description: "")

        apiClient.execute(ReadEntityEndpoint())
            .sink { completion in
                XCTAssertEqual(completion, .finished)
                completionExpectation.fulfill()
            } receiveValue: { entity in
                XCTAssertEqual(entity, mockEntity)
                valueExpectation.fulfill()
            }
            .store(in: &subscriptions)

        waitForExpectations(timeout: 0.25)
    }

    func testExecuteReadableApiEndpointErrorStatusCode() {
        let appConfiguration = MockAppConfiguration()
        let mockEntity = Entity(name: "Name")
        let apiClient = ApiClient(
            dataPublisher: { request in
                self.mockDataPublisher(url: request.url, entity: mockEntity, statusCode: 500)
            },
            appConfiguration: appConfiguration
        )

        let completionExpectation = expectation(description: "")

        var didReceiveValue = false
        apiClient.execute(ReadEntityEndpoint())
            .sink { completion in
                switch completion {
                case .failure(let error):
                    XCTAssertEqual(error, .invalidStatusCode)
                case .finished:
                    XCTFail("Shouldn't have finished normally")
                }
                completionExpectation.fulfill()
            } receiveValue: { entity in
                didReceiveValue = true
            }
            .store(in: &subscriptions)

        waitForExpectations(timeout: 0.25)

        XCTAssertFalse(didReceiveValue)
    }

    func testExecuteSendableApiEndpoint() {
        let appConfiguration = MockAppConfiguration()
        let apiClient = ApiClient(
            dataPublisher: { request in
                self.mockDataPublisher(url: request.url, entity: nil, statusCode: 200)
            },
            appConfiguration: appConfiguration
        )

        let valueExpectation = expectation(description: "")
        let completionExpectation = expectation(description: "")

        apiClient.execute(SendEntityEndpoint(input: Entity(name: "Name")))
            .sink { completion in
                XCTAssertEqual(completion, .finished)
                completionExpectation.fulfill()
            } receiveValue: {
                // Void is received
                valueExpectation.fulfill()
            }
            .store(in: &subscriptions)

        waitForExpectations(timeout: 0.25)
    }

    func testExecuteSendableApiEndpointErrorStatusCode() {
        let appConfiguration = MockAppConfiguration()
        let apiClient = ApiClient(
            dataPublisher: { request in
                self.mockDataPublisher(url: request.url, entity: nil, statusCode: 500)
            },
            appConfiguration: appConfiguration
        )

        let completionExpectation = expectation(description: "")

        var didReceiveValue = false
        apiClient.execute(SendEntityEndpoint(input: Entity(name: "Name")))
            .sink { completion in
                switch completion {
                case .failure(let error):
                    XCTAssertEqual(error, .invalidStatusCode)
                case .finished:
                    XCTFail("Shouldn't have finished normally")
                }
                completionExpectation.fulfill()
            } receiveValue: {
                didReceiveValue = true
            }
            .store(in: &subscriptions)

        waitForExpectations(timeout: 0.25)

        XCTAssertFalse(didReceiveValue)
    }

    func testExecuteSendableReadableApiEndpoint() {
        let appConfiguration = MockAppConfiguration()
        let mockEntity = Entity(name: "Name")
        let apiClient = ApiClient(
            dataPublisher: { request in
                self.mockDataPublisher(url: request.url, entity: mockEntity, statusCode: 200)
            },
            appConfiguration: appConfiguration
        )

        let valueExpectation = expectation(description: "")
        let completionExpectation = expectation(description: "")

        apiClient.execute(SendReadEntityEndpoint(input: Entity(name: "Name2")))
            .sink { completion in
                XCTAssertEqual(completion, .finished)
                completionExpectation.fulfill()
            } receiveValue: { entity in
                XCTAssertEqual(entity, mockEntity)
                valueExpectation.fulfill()
            }
            .store(in: &subscriptions)

        waitForExpectations(timeout: 0.25)
    }
}

private extension ApiClientTests {

    struct Entity: Codable, Equatable {
        let name: String

        init(name: String) {
            self.name = name
        }
    }

    struct ReadEntityEndpoint: ReadableApiEndpoint {
        let path = "path"
        let method = ApiMethod.get
        let successStatusCodes: Set<Int> = [200]

        typealias Output = Entity
    }

    struct SendEntityEndpoint: SendableApiEndpoint {
        let path = "path"
        let method = ApiMethod.post
        let successStatusCodes: Set<Int> = [200]
        let input: Entity

        init(input: Entity) {
            self.input = input
        }
    }

    struct SendReadEntityEndpoint: SendableReadableApiEndpoint {
        let path = "path"
        let method = ApiMethod.post
        let successStatusCodes: Set<Int> = [200]
        let input: Entity

        typealias Output = Entity

        init(input: Entity) {
            self.input = input
        }
    }

    struct MockAppConfiguration: AppConfiguration {
        let environmentName = "name"
        let apiBaseUrl = URL(string: "https://domain.com/staging/")!
    }

    func mockDataPublisher(url: URL?, entity: Entity?, statusCode: Int) -> AnyPublisher<(data: Data, response: HTTPURLResponse), ApiError> {
        let data: Data
        let response: HTTPURLResponse
        if let entity = entity {
            guard let aData = try? JSONEncoder().encode(entity),
                  let url = url,
                  let aResponse = HTTPURLResponse(url: url, statusCode: statusCode, httpVersion: nil, headerFields: nil) else {
                return Fail(outputType: (data: Data, response: HTTPURLResponse).self, failure: ApiError.unknown)
                    .eraseToAnyPublisher()
            }
            data = aData
            response = aResponse
        } else {
            guard let url = url,
                  let aResponse = HTTPURLResponse(url: url, statusCode: statusCode, httpVersion: nil, headerFields: nil) else {
                return Fail(outputType: (data: Data, response: HTTPURLResponse).self, failure: ApiError.unknown)
                    .eraseToAnyPublisher()
            }
            data = Data()
            response = aResponse
        }
        return Just((data: data, response: response))
            .setFailureType(to: ApiError.self)
            .eraseToAnyPublisher()
    }
}
