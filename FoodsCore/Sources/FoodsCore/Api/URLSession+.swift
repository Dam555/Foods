//
//  URLSession+.swift
//  
//
//  Created by Damjan on 16.08.2022.
//

import Combine
import Foundation

extension URLSession {

    public func apiClientDataPublisher(for request: URLRequest) -> AnyPublisher<(data: Data, response: HTTPURLResponse), ApiError> {
        dataTaskPublisher(for: request)
            .tryMap { dataResponse -> (Data, HTTPURLResponse) in
                guard let httpUrlResponse = dataResponse.response as? HTTPURLResponse else { throw ApiError.invalidResponse}
                return (dataResponse.data, httpUrlResponse)
            }
            .mapError { error in
                ApiError(error)
            }
            .eraseToAnyPublisher()
    }
}
