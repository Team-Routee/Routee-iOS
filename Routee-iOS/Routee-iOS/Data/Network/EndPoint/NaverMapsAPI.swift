//
//  NaverMapsAPI.swift
//  Routee-iOS
//
//  Created by LEESANGYUP on 7/9/26.
//

import Foundation

import Alamofire

enum NaverMapsAPI {
    case reverseGeocode(latitude: Double, longitude: Double)
}

extension NaverMapsAPI: ExternalEndPoint {
    var provider: ExternalAPIProvider {
        .naverMaps
    }
    
    var basePath: String {
        switch self {
        case .reverseGeocode:
            "/map-reversegeocode/v2"
        }
    }
    
    var path: String {
        switch self {
        case .reverseGeocode:
            "/gc"
        }
    }
    
    var method: HTTPMethod {
        switch self {
        case .reverseGeocode:
            .get
        }
    }
    
    var headers: HeaderType {
        switch self {
        case .reverseGeocode:
            .naverMaps
        }
    }
    
    var parameterEncoding: ParameterEncoding {
        switch self {
        case .reverseGeocode:
            URLEncoding.default
        }
    }
    
    var queryParameters: [String: String]? {
        switch self {
        case .reverseGeocode(let latitude, let longitude):
            [
                "coords": "\(longitude),\(latitude)",
                "orders": "roadaddr,addr",
                "output": "json"
            ]
        }
    }
    
    var bodyParameters: Parameters? {
        switch self {
        case .reverseGeocode:
            nil
        }
    }
}
