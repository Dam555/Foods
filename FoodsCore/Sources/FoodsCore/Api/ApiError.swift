//
//  ApiError.swift
//  
//
//  Created by Damjan on 15.08.2022.
//

import Foundation

public enum ApiError: Error {
    case noInternet
    case invalidParam
    case invalidUrl
    case invalidResponse
    case invalidStatusCode
    case decodingFailed
    case encodingFailed
    case timedOut
    case unknown

    public init(_ error: Error) {
        switch error {
        case let apiError as ApiError:
            self = apiError
        case let urlError as URLError:
            switch urlError.code {
            case .notConnectedToInternet: self = .noInternet
            case .badURL, .unsupportedURL: self = .invalidUrl
            case .timedOut: self = .timedOut
            default: self = .unknown
            }
        case is DecodingError:
            self = .decodingFailed
        case is EncodingError:
            self = .encodingFailed
        default: self = .unknown
        }
    }
}
