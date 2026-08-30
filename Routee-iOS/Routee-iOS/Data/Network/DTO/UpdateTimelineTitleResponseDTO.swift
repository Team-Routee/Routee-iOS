//
//  UpdateTimelineTitleResponseDTO.swift
//  Routee-iOS
//
//  Created by LEESANGYUP on 8/31/26.
//

import Foundation

struct UpdateTimelineTitleResponseDTO: Decodable, Sendable {
    let timelineId: Int64
    let title: String
}
