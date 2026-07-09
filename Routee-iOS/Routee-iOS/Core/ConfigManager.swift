//
//  ConfigManager.swift
//  Routee-iOS
//
//  Created by LEESANGYUP on 6/30/26.
//

import Foundation

enum ConfigKey: String {
    case baseURL = "BASE_URL"
    case naverMapBaseURL = "NAVER_MAP_BASE_URL"
    case naverMapClientID = "NAVER_MAP_CLIENT_ID"
    case naverMapClientSecret = "NAVER_MAP_CLIENT_SECRET"
}

struct ConfigManager {
    private static func toString(for key: ConfigKey) -> String {
        guard let value = Bundle.main.infoDictionary?[key.rawValue] as? String
        else {
            RouteeLogger.error(RouteeError.configError)
            return ""
        }
        return value
    }
    
    static var baseURL: String { toString(for: .baseURL) }
    static var naverMapBaseURL: String { toString(for: .naverMapBaseURL) }
    static var naverMapClientID: String { toString(for: .naverMapClientID) }
    static var naverMapClientSecret: String { toString(for: .naverMapClientSecret) }
}
