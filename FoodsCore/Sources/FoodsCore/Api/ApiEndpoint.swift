//
//  ApiEndpoint.swift
//  
//
//  Created by Damjan on 15.08.2022.
//

import Foundation

public protocol ApiEndpoint {

    var path: String { get }
    var method: ApiMethod { get }
    var successStatusCodes: Set<Int> { get }
}

public protocol ReadableApiEndpoint: ApiEndpoint {

    associatedtype Output: Decodable

    var jsonDecoder: JSONDecoder { get }
}

public extension ReadableApiEndpoint {

    var jsonDecoder: JSONDecoder { JSONDecoder() }
}

public protocol SendableApiEndpoint: ApiEndpoint {

    associatedtype Input: Encodable

    var input: Input { get }
    var jsonEncoder: JSONEncoder { get }
}

public extension SendableApiEndpoint {

    var jsonEncoder: JSONEncoder { JSONEncoder() }
}

public protocol SendableReadableApiEndpoint: SendableApiEndpoint, ReadableApiEndpoint { }
