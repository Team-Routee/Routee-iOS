//
//  UpdateArchiveActivityTitleResponseDTO.swift
//  Routee-iOS
//
//  Created by 초긍정행운의포춘쿠키 on 8/19/26.
//

import Foundation

struct UpdateArchiveActivityTitleResponseDTO: Decodable, Sendable {
    let activityId: Int64
    let title: String
}
