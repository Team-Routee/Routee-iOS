//
//  ActivityCreateRequestDTO.swift
//  Routee-iOS
//
//  Created by LEESANGYUP on 7/15/26.
//

import Foundation

struct ActivityCreateRequestDTO: Encodable {
    let activityType: String
    let startedAt: String
}
