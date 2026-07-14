//
//  RegisterRequestDTO.swift
//  Routee-iOS
//
//  Created by LEESANGYUP on 7/13/26.
//

import Foundation

struct RegisterRequestDTO: Encodable {
    let nickname: String
    let idToken: String
    let provider: String
}
