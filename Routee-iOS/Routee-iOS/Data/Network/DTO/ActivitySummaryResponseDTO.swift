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

extension ActivitySummaryResponseDTO {
    func toModel() -> [ActivitySummaryModel] {
        result.map {
            ActivitySummaryModel(
                activityDate: $0.activityDate,
                totalDurationMinutes: $0.totalDurationMinutes,
                activityCount: $0.activityCount,
                coverImageUrl: $0.coverImageUrl
            )
        }
    }
}
