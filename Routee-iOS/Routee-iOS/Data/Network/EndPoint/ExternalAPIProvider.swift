//
//  ExternalAPIProvider.swift
//  Routee-iOS
//
//  Created by LEESANGYUP on 7/9/26.
//

import Foundation

enum ExternalAPIProvider {
    case naverMaps
    
    var baseURL: String {
        switch self {
        case .naverMaps:
            ConfigManager.naverMapBaseURL
        }
    }
}

protocol ExternalEndPoint: EndPoint {
    var provider: ExternalAPIProvider { get }
}

extension ExternalEndPoint {
    var baseURL: String {
        provider.baseURL
    }
}
