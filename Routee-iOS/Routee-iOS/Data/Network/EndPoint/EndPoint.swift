//
//  EndPoint.swift
//  Routee-iOS
//
//  Created by LEESANGYUP on 6/30/26.
//

import Foundation

import Alamofire

protocol EndPoint {
    var baseURL: String { get }
    var basePath: String { get }
    var path: String { get }
    var method: HTTPMethod { get }
    var headers: HeaderType { get }
    var parameterEncoding: ParameterEncoding { get }
    var queryParameters: [String: String]? { get }
    var bodyParameters: Parameters? { get }
    var requestURL: URL { get }
}

protocol RouteeEndPoint: EndPoint { }

extension EndPoint {
    var requestURL: URL {
        let urlString = baseURL + basePath + path
        
        guard var urlComponents = URLComponents(string: urlString) else {
            RouteeLogger.error(RouteeError.URLError)
            return URL(filePath: "")
        }
        
        if let queryParameters {
            urlComponents.queryItems = queryParameters.map {
                URLQueryItem(name: $0, value: $1)
            }
        }
        
        guard let url = urlComponents.url else {
            RouteeLogger.error(RouteeError.URLError)
            return URL(filePath: "")
        }
        
        return url
    }
}

enum HeaderType {
    case basic
    case basicTimeZone(timeZone: String)
    case withAuth(accessToken: String)
    case withAuthTimeZone(accessToken: String, timeZone: String)
    case appleLoginHeader(identityToken: String, authorizationCode: String)
    case refresh(accessToken: String)
    case naverMaps
    
    var value: HTTPHeaders {
        switch self {
        case .basic:
            return ["Content-Type": "application/json"]
        case .basicTimeZone(let timeZone):
            return [
                "Content-Type": "application/json",
                "Time-Zone": timeZone
            ]
        case .withAuth(let accessToken):
            return [
                "Content-Type": "application/json",
                "Authorization": "Bearer \(accessToken)"
            ]
        case .withAuthTimeZone(let accessToken, let timeZone):
            return [
                "Content-Type": "application/json",
                "Authorization": "Bearer \(accessToken)",
                "Time-Zone": timeZone
            ]
        case .appleLoginHeader(let identityToken, let authorizationCode):
            return [
                "Content-Type": "application/json",
                "Authorization": "Bearer \(identityToken)",
                "X-Apple-Code": "\(authorizationCode)"
            ]
        case .refresh(let accessToken):
            return [
                "Content-Type": "application/json",
                "Authorization": "Bearer \(accessToken)"
            ]
        case .naverMaps:
            return [
                "X-NCP-APIGW-API-KEY-ID": ConfigManager.naverMapClientID,
                "X-NCP-APIGW-API-KEY": ConfigManager.naverMapClientSecret
            ]
        }
    }
}

extension RouteeEndPoint {
    var baseURL: String {
        ConfigManager.baseURL
    }
}
