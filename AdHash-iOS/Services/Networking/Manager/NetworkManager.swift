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

//final class NetworkError {
//    let message: String
//    let statusCode: Int
//
//    init(errorMessage: String, statusCode: Int) {
//        self.message = errorMessage
//        self.statusCode = statusCode
//    }
//}

enum NetworkError: Error {
    case noInternet
    case emptyData
    case badRequest
    case unAuthUser
    case authFailed
    case notFound
    case validationError
    case serverError
    case unknownError
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
    
    func perform(_ request: URLRequest, completion: @escaping ((Data?, NetworkError?) -> Void)) {
        session.dataTask(with: request, completionHandler: { (data, response, error) in
            guard error == nil else {
                completion(nil, .noInternet)
                return
            }
            
            if let response = response as? HTTPURLResponse {
                let responseResult = response.statusCode
                switch responseResult {
                case 200 ..< 300:
                    guard let responseData = data else {
                        completion(nil, .emptyData)
                        return
                    }
                    completion(responseData, nil)
                case 400:
                    completion(nil, .badRequest)
                case 401:
                    completion(nil, .unAuthUser)
                case 403:
                    completion(nil, .authFailed)
                case 404:
                    completion(nil, .notFound)
                case 422:
                    completion(nil, .validationError)
                case 500 ..< 512:
                    completion(nil, .serverError)
                default:
                    completion(nil, .unknownError)
                }
                
            }
            
        }).resume()
    }
}
