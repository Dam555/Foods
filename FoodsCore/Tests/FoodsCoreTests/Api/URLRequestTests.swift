//
//  URLRequestTests.swift
//  
//
//  Created by Damjan on 17.08.2022.
//

@testable import FoodsCore
import XCTest

class URLRequestTests: XCTestCase {

    let baseUrl = URL(string: "https://domain.com/staging/")!

    func testReadableApiEndpoint() throws {
        let endpoint = ReadEntityEndpoint()
        let urlRequest = try URLRequest(endpoint: endpoint, baseUrl: baseUrl)

        let url = URL(string: endpoint.path, relativeTo: baseUrl)!.absoluteURL
        XCTAssertEqual(urlRequest.url, url)
        XCTAssertEqual(urlRequest.httpMethod, ApiMethod.get.rawValue)
    }

    func testSendableApiEndpoint() throws {
        let entity = Entity(name: "Name")
        let endpoint = SendEntityEndpoint(input: entity)
        let urlRequest = try URLRequest(endpoint: endpoint, baseUrl: baseUrl)

        let url = URL(string: endpoint.path, relativeTo: baseUrl)!.absoluteURL
        XCTAssertEqual(urlRequest.url, url)
        XCTAssertEqual(urlRequest.httpMethod, ApiMethod.post.rawValue)

        let entityData = try endpoint.jsonEncoder.encode(entity)
        XCTAssertEqual(urlRequest.httpBody, entityData)
    }

    func testSendableReadableApiEndpoint() throws {
        let entity = Entity(name: "Name")
        let endpoint = SendReadEntityEndpoint(input: entity)
        let urlRequest = try URLRequest(endpoint: endpoint, baseUrl: baseUrl)

        let url = URL(string: endpoint.path, relativeTo: baseUrl)!.absoluteURL
        XCTAssertEqual(urlRequest.url, url)
        XCTAssertEqual(urlRequest.httpMethod, ApiMethod.post.rawValue)

        let entityData = try endpoint.jsonEncoder.encode(entity)
        XCTAssertEqual(urlRequest.httpBody, entityData)
    }
}

private extension URLRequestTests {

    struct Entity: Codable {
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
}
