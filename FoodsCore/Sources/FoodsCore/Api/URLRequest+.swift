//
//  URLRequest+.swift
//  
//
//  Created by Damjan on 15.08.2022.
//

import Foundation

extension URLRequest {

    init<Endpoint>(endpoint: Endpoint, baseUrl: URL) throws where Endpoint: ReadableApiEndpoint {
        try self.init(path: endpoint.path, baseUrl: baseUrl, httpMethod: endpoint.method.rawValue)
    }

    init<Endpoint>(endpoint: Endpoint, baseUrl: URL) throws where Endpoint: SendableApiEndpoint {
        try self.init(path: endpoint.path, baseUrl: baseUrl, httpMethod: endpoint.method.rawValue, input: endpoint.input, jsonEncoder: endpoint.jsonEncoder)
    }

    init<Endpoint>(endpoint: Endpoint, baseUrl: URL) throws where Endpoint: SendableReadableApiEndpoint {
        try self.init(path: endpoint.path, baseUrl: baseUrl, httpMethod: endpoint.method.rawValue, input: endpoint.input, jsonEncoder: endpoint.jsonEncoder)
    }
}

private extension URLRequest {

    init(path: String, baseUrl: URL, httpMethod: String) throws {
        guard let url = URL(string: path, relativeTo: baseUrl) else { throw ApiError.invalidUrl }
        self.init(url: url)
        self.httpMethod = httpMethod
    }

    init<Input>(path: String, baseUrl: URL, httpMethod: String, input: Input, jsonEncoder: JSONEncoder) throws where Input: Encodable {
        try self.init(path: path, baseUrl: baseUrl, httpMethod: httpMethod)
        let inputData = try jsonEncoder.encode(input)
        self.httpBody = inputData
    }
}
