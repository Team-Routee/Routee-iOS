//
//  ConfigManager.swift
//  Routee-iOS
//
//  Created by LEESANGYUP on 6/30/26.
//

import Foundation

enum ConfigKey: String {
    case baseURL = "BASE_URL"
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
}
