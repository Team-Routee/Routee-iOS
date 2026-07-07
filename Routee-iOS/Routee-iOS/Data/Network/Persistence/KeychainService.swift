//
//  KeychainService.swift
//  Routee-iOS
//
//  Created by LEESANGYUP on 7/7/26.
//

import Foundation

protocol KeychainService {
    func create(_ key: KeyType, token: String)
    func read(_ key: KeyType) -> String
    func delete(_ key: KeyType)
}

struct DefaultKeychainService: KeychainService {
    func create(_ key: KeyType, token: String) {
        KeyChainManager.create(key: key, token: token)
    }
    
    func read(_ key: KeyType) -> String {
        KeyChainManager.read(key: key) ?? ""
    }
    
    func delete(_ key: KeyType) {
        KeyChainManager.delete(key: key)
    }
}
