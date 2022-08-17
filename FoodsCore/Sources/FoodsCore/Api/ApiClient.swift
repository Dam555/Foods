//
//  ApiClient.swift
//  
//
//  Created by Damjan on 15.08.2022.
//

import Combine
import Foundation

public class ApiClient {

    public typealias ApiClientDataPublisher = (URLRequest) -> AnyPublisher<(data: Data, response: HTTPURLResponse), ApiError>

    let dataPublisher: ApiClientDataPublisher
    let appConfiguration: AppConfiguration

    public init(dataPublisher: @escaping ApiClientDataPublisher = URLSession.shared.apiClientDataPublisher(for:), appConfiguration: AppConfiguration = AppEnvironment.default) {
        self.dataPublisher = dataPublisher
        self.appConfiguration = appConfiguration
    }

    public func execute<Endpoint>(_ endpoint: Endpoint) -> AnyPublisher<Endpoint.Output, ApiError> where Endpoint: ReadableApiEndpoint {
        Just(endpoint)
            .tryMap { endpoint in
                try URLRequest(endpoint: endpoint, baseUrl: appConfiguration.apiBaseUrl)
            }
            .mapError { error in
                ApiError(error)
            }
            .flatMap { urlRequest in
                self.endpointOutputPublisher(for: urlRequest, successStatusCodes: endpoint.successStatusCodes, type: Endpoint.Output.self, jsonDecoder: endpoint.jsonDecoder)
            }
            .eraseToAnyPublisher()
    }

    public func execute<Endpoint>(_ endpoint: Endpoint) -> AnyPublisher<Void, ApiError> where Endpoint: SendableApiEndpoint {
        Just(endpoint)
            .tryMap { endpoint in
                try URLRequest(endpoint: endpoint, baseUrl: appConfiguration.apiBaseUrl)
            }
            .mapError { error in
                ApiError(error)
            }
            .flatMap { urlRequest in
                self.endpointVoidPublisher(for: urlRequest, successStatusCodes: endpoint.successStatusCodes)
            }
            .eraseToAnyPublisher()
    }

    public func execute<Endpoint>(_ endpoint: Endpoint) -> AnyPublisher<Endpoint.Output, ApiError> where Endpoint: SendableReadableApiEndpoint {
        Just(endpoint)
            .tryMap { endpoint in
                try URLRequest(endpoint: endpoint, baseUrl: appConfiguration.apiBaseUrl)
            }
            .mapError { error in
                ApiError(error)
            }
            .flatMap { urlRequest in
                self.endpointOutputPublisher(for: urlRequest, successStatusCodes: endpoint.successStatusCodes, type: Endpoint.Output.self, jsonDecoder: endpoint.jsonDecoder)
            }
            .eraseToAnyPublisher()
    }
}

private extension ApiClient {

    // Publisher for endpoints that return data
    func endpointOutputPublisher<Output>(for request: URLRequest, successStatusCodes: Set<Int>, type: Output.Type, jsonDecoder: JSONDecoder) -> AnyPublisher<Output, ApiError> where Output: Decodable {
        dataPublisher(request)
            .tryMap { dataResponse -> Data in
                guard successStatusCodes.contains(dataResponse.response.statusCode) else { throw ApiError.invalidStatusCode}
                return dataResponse.data
            }
            .decode(type: Output.self, decoder: jsonDecoder)
            .mapError { error in
                ApiError(error)
            }
            .eraseToAnyPublisher()
    }

    // Publisher for endpoints that don't return any data
    func endpointVoidPublisher(for request: URLRequest, successStatusCodes: Set<Int>) -> AnyPublisher<Void, ApiError> {
        dataPublisher(request)
            .tryMap { dataResponse -> Void in
                guard successStatusCodes.contains(dataResponse.response.statusCode) else { throw ApiError.invalidStatusCode}
                return ()
            }
            .mapError { error in
                ApiError(error)
            }
            .eraseToAnyPublisher()
    }
}
