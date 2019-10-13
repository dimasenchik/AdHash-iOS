//
//  NetworkManager.swift
//  EvoZhuk
//
//  Created by Dima Senchik on 7/7/19.
//  Copyright © 2019 Dima Senchik. All rights reserved.
//

import Foundation

typealias emptySuccess = (() -> ())
typealias onSuccess<T> = ((T) -> ())
typealias onFailure<T> = ((T) -> ())

final class NetworkError {
    let message: String
    let statusCode: Int
    
    init(errorMessage: String, statusCode: Int) {
        self.message = errorMessage
        self.statusCode = statusCode
    }
}

enum Result<String>{
    case success
    case failure(String)
}

final class NetworkConfiguration {
    static var baseEnvironment: NetworkEnvironment = .production
}

struct NetworkManager {
    static let shared = NetworkManager()
    
    private init() {}
    
    let session = URLSession.shared
    
    func perform(_ request: URLRequest, onSuccess: @escaping ((Data) -> ()), onFailure: @escaping onFailure<NetworkError>) {
        session.dataTask(with: request, completionHandler: { (data, response, error) in
            guard error == nil else {
                onFailure(NetworkError(errorMessage: "NetworkErrors.noInternet", statusCode: 1))
                return
            }
            
            if let response = response as? HTTPURLResponse {
                let responseResult = response.statusCode
                switch responseResult {
                case 200 ..< 300:
                    guard let responseData = data else {
                        onFailure(NetworkError(errorMessage: "NetworkErrors.emptyData", statusCode: response.statusCode))
                        return
                    }
                    onSuccess(responseData)
                case 400:
                    onFailure(NetworkError(errorMessage: "NetworkErrors.badRequest", statusCode: 400))
                case 401:
                    onFailure(NetworkError(errorMessage: "NetworkErrors.unauthUser", statusCode: 401))
                case 403:
                    onFailure(NetworkError(errorMessage: "NetworkErrors.authFailed", statusCode: 403))
                case 404:
                    onFailure(NetworkError(errorMessage: "NetworkErrors.notFound", statusCode: 404))
                case 422:
                    onFailure(NetworkError(errorMessage: "NetworkErrors.validationError", statusCode: 422))
                case 500 ..< 512:
                    onFailure(NetworkError(errorMessage: "NetworkErrors.serverError", statusCode: response.statusCode))
                default:
                    onFailure(NetworkError(errorMessage: "NetworkErrors.unknownError", statusCode: response.statusCode))
                }
                
            }
            
        }).resume()
    }
}
