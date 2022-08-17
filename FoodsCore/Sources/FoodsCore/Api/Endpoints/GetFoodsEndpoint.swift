//
//  GetFoodsEndpoint.swift
//  
//
//  Created by Damjan on 15.08.2022.
//

import Foundation

public struct Food: Decodable, Identifiable, Equatable {
    public let id: Int
    public let name: String

    public init(id: Int, name: String) {
        self.id = id
        self.name = name
    }
}

public struct GetFoodsEndpoint: ReadableApiEndpoint {
    public let path: String
    public let method = ApiMethod.get
    public let successStatusCodes: Set<Int> = [200]

    public typealias Output = [Food]

    public init(kv: String) throws {
        var components = URLComponents()
        components.path = "search"
        components.queryItems = [URLQueryItem(name: "kv", value: kv)]
        guard let url = components.url else { throw ApiError.invalidParam }
        path = url.absoluteString
    }
}
