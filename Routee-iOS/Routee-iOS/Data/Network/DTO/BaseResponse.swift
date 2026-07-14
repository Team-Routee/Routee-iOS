//
//  BaseResponse.swift
//  Routee-iOS
//
//  Created by LEESANGYUP on 6/30/26.
//

import Foundation

struct BaseResponse<T: Decodable & Sendable>: Decodable, Sendable {
    let status: Int
    let code: String
    let message: String
    let data: T?
}

struct EmptyResponse: Decodable, Sendable {
    let status: Int
    let code: String
    let message: String
}
