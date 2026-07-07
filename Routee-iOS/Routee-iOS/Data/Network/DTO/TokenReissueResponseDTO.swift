//
//  TokenReissueResponseDTO.swift
//  Routee-iOS
//
//  Created by LEESANGYUP on 7/7/26.
//

import Foundation

struct TokenReissueResponseDTO: Decodable {
    let accessToken: String
    let refreshToken: String
    let tokenType: String
}
