//
//  AuthRepository.swift
//  Routee-iOS
//
//  Created by LEESANGYUP on 7/2/26.
//

import Foundation

protocol AuthRepository {
    func appleLogin(identityToken: String, authorizationCode: String) async throws
}
