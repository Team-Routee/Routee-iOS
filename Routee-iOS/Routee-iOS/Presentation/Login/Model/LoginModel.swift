//
//  LoginModel.swift
//  Routee-iOS
//
//  Created by LEESANGYUP on 7/6/26.
//

import Foundation

struct LoginModel: Encodable {
    let identityToken: String
    let appleUserIdentifier: String
    let userName: String?
}
