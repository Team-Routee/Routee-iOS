//
//  EndPoint.swift
//  Routee-iOS
//
//  Created by LEESANGYUP on 6/30/26.
//

import Foundation

import Alamofire

protocol EndPoint {
    var basePath: String { get }
    var path: String { get }
    var method: HTTPMethod { get }
    var headers: HeaderType { get }
    var parameterEncoding: ParameterEncoding { get }
    var queryParameters: [String: String]? { get }
    var bodyParameters: Parameters? { get }
    var requestURL: URL { get }
}

extension EndPoint {
    var requestURL: URL {
        let baseURL = ConfigManager.baseURL
        let urlString = baseURL + basePath + path
        
        guard var urlComponents = URLComponents(string: urlString) else {
            RouteeLogger.error(RouteeError.URLError)
            return URL(string: "")!
        }
        
        if let queryParameters {
            urlComponents.queryItems = queryParameters.map {
                URLQueryItem(name: $0, value: $1)
            }
        }
        
        guard let url = urlComponents.url else {
            RouteeLogger.error(RouteeError.URLError)
            return URL(string: "")!
        }
        
        return url
    }
}

enum HeaderType {
    case basic
    case withAuth
    case appleLoginHeader(identityToken: String, authorizationCode: String)
    
    var value: HTTPHeaders {
        switch self {
        case .basic:
            return ["Content-Type": "application/json"]
        case .withAuth:
            return [
                "Content-Type": "application/json",
                "X-Requires-Auth": "true"
            ]
        case .appleLoginHeader(let identityToken, let authorizationCode):
            return [
                "Content-Type": "application/json",
                "Authorization": "Bearer \(identityToken)",
                "X-Apple-Code": "\(authorizationCode)"
            ]
        }
    }
}
