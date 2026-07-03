//
//  TokenManager.swift
//  Routee-iOS
//
//  Created by LEESANGYUP on 7/2/26.
//

import Foundation

enum KeyType {
    case accessToken
    case refreshToken
}

protocol TokenManager {
    func save(key: KeyType, token: String)
    func load(key: KeyType) -> String?
    func delete(key: KeyType)
}
