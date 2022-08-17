//
//  GetFoodsEndpointTests.swift
//  
//
//  Created by Damjan on 17.08.2022.
//

@testable import FoodsCore
import XCTest

class GetFoodsEndpointTests: XCTestCase {

    let baseUrl = URL(string: "https://domain.com/staging/")!

    func testEndpoint() throws {
        let endpoint = try GetFoodsEndpoint(kv: "abc d&")

        XCTAssertEqual(endpoint.path, "search?kv=abc%20d%26")
        XCTAssertEqual(endpoint.method, ApiMethod.get)
        XCTAssertEqual(endpoint.successStatusCodes, [200])
    }
}
