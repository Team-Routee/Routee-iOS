//
//  KeychainManager.swift
//  Routee-iOS
//
//  Created by LEESANGYUP on 7/7/26.
//

import Foundation
import Security

enum KeyType: String, CaseIterable {
    case accessToken
    case refreshToken
    case appleUserID
}

enum KeyChainManager {
    private static let service = Bundle.main.bundleIdentifier ?? "Routee-iOS"
    
    static func create(key: KeyType, token: String) {
        guard let tokenData = token.data(using: .utf8, allowLossyConversion: false) else {
            RouteeLogger.error(RouteeError.unknownError)
            return
        }
        
        let query: [CFString: Any] = [
            kSecClass: kSecClassGenericPassword,
            kSecAttrService: service,
            kSecAttrAccount: key.rawValue
        ]
        
        let attributes: [CFString: Any] = [
            kSecValueData: tokenData
        ]
        
        let updateStatus = SecItemUpdate(query as CFDictionary, attributes as CFDictionary)
        if updateStatus == errSecSuccess {
            return
        }
        
        var addQuery = query
        addQuery[kSecValueData] = tokenData
        
        let addStatus = SecItemAdd(addQuery as CFDictionary, nil)
        if addStatus != errSecSuccess {
            RouteeLogger.error(
                RouteeError.networkError(statusCode: Int(addStatus), message: "failed to save Token")
            )
        }
    }
    
    static func read(key: KeyType) -> String? {
        let query: [CFString: Any] = [
            kSecClass: kSecClassGenericPassword,
            kSecAttrService: service,
            kSecAttrAccount: key.rawValue,
            kSecReturnData: kCFBooleanTrue as Any,
            kSecMatchLimit: kSecMatchLimitOne
        ]
        
        var dataTypeRef: AnyObject?
        let status = SecItemCopyMatching(query as CFDictionary, &dataTypeRef)
        
        if status == errSecSuccess {
            if let retrievedData: Data = dataTypeRef as? Data {
                let value = String(data: retrievedData, encoding: String.Encoding.utf8)
                return value
            } else { return nil }
        } else {
            RouteeLogger.data("failed to loading, status code = \(status)")
            return nil
        }
    }
    
    static func delete(key: KeyType) {
        let query: [CFString: Any] = [
            kSecClass: kSecClassGenericPassword,
            kSecAttrService: service,
            kSecAttrAccount: key.rawValue
        ]
        let status = SecItemDelete(query as CFDictionary)
        if status != errSecSuccess && status != errSecItemNotFound {
            RouteeLogger.error(
                RouteeError.networkError(statusCode: Int(status), message: "failed to delete Token")
            )
        }
    }
}
