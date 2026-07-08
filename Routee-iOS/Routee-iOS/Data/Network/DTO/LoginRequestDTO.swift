//
//  LoginRequestDTO.swift
//  Routee-iOS
//
//  Created by LEESANGYUP on 7/6/26.
//

import Foundation

struct LoginRequestDTO: Encodable {
    let provider: String
    let idToken: String
    let nickname: String
}
