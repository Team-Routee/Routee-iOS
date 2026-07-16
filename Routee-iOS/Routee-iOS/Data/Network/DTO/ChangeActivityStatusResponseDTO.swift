//
//  ChangeActivityStatusResponseDTO.swift
//  Routee-iOS
//
//  Created by LEESANGYUP on 7/16/26.
//

import Foundation

struct ChangeActivityStatusResponseDTO: Decodable, Sendable {
    let activityId: Int64
    let status: String
}
