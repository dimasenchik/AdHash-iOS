//
//  ZhukEndPoint.swift
//  EvoZhuk
//
//  Created by Dima Senchik on 7/7/19.
//  Copyright © 2019 Dima Senchik. All rights reserved.
//

import Foundation

enum NetworkEnvironment {
    case test
    case production
    
    var basePath: String {
        switch self {
        case .test:
            return "https://bidder.adhash.org"
        case .production:
            return "https://bidder.adhash.org"
        }
    }
}


final class RequestBuilder {
    
    enum RequestPath {
        case firstStep
        case none
        
        var path: String {
            switch self {
            case .firstStep:
                return "/protocol.php?action=rtb_sdk&version=1.0"
            case .none:
                return ""
            }
        }
    }
    
    enum HeadersType {
        case typical
        case custom
    }
    
    static func build(_ httpMethod: HTTPMethod = .get , baseUrl: String = NetworkConfiguration.baseEnvironment.basePath, headersType: HeadersType, body: Any? = nil, queryItems: String? = nil, urlParameter: String = "", requestType: RequestPath) -> URLRequest? {
        
        var configuredURL = URL(string: "\(baseUrl)\(requestType.path)")
        
        if urlParameter != "" {
            configuredURL = URL(string: "\(baseUrl)\(requestType.path)/\(urlParameter)")
        }
        
        if let queryString = queryItems {
			if let formattedString = "\(baseUrl)?\(queryString)".addingPercentEncoding(withAllowedCharacters: CharacterSet.urlQueryAllowed) {
				configuredURL = URL(string: formattedString)
			}
        }
        
        var httpBody: Data? = nil
        
        if let requestURL = configuredURL {
            
            if body != nil {
                httpBody = try? JSONSerialization.data(withJSONObject: body, options: [])
            }
            var request = URLRequest(url: requestURL)
            configureRequestHeaders(type: headersType, request: &request)
            request.httpMethod = httpMethod.rawValue
            request.httpBody = httpBody
            
            return request
        }
        
        return nil
    }

}

// MARK: - Private methods
private extension RequestBuilder {
    static func configureRequestHeaders(type: HeadersType, request: inout URLRequest) {
        switch type {
        case .typical:
            request.setValue("application/json; charset=utf-8", forHTTPHeaderField: "Content-Type")
        case .custom:
            request.setValue("Custom field", forHTTPHeaderField: "http header field")
        }
    }
}
