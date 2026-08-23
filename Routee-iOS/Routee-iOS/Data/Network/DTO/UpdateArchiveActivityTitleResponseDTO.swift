//
//  UpdateArchiveActivityTitleResponseDTO.swift
//  Routee-iOS
//
//  Created by ysh on 8/19/26.
//

import Foundation

struct UpdateArchiveActivityTitleResponseDTO: Decodable, Sendable {
    let activityId: Int64
    let title: String
}
