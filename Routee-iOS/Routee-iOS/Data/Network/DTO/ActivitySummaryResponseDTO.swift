//
//  ActivitySummaryResponseDTO.swift
//  Routee-iOS
//
//  Created by 초긍정행운의포춘쿠키 on 7/14/26.
//

import Foundation

struct ActivitySummaryResponseDTO: Decodable, Sendable {
    let result: [ActivitySummaryResult]
    let year: Int
    let month: Int

    struct ActivitySummaryResult: Decodable, Sendable {
        let activityDate: String
        let totalDurationMinutes: Int
        let activityCount: Int
        let coverImageUrl: String?
    }
}
