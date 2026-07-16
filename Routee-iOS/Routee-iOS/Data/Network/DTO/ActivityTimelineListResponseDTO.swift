//
//  ActivityTimelineListResponseDTO.swift
//  Routee-iOS
//
//  Created by 초긍정행운의포춘쿠키 on 7/15/26.
//

import Foundation

struct ActivityTimelineListResponseDTO: Decodable, Sendable {
    let activityId: Int64
    let timelines: [Timeline]

    struct Timeline: Decodable, Sendable {
        let timelineId: Int64
        let title: String
        let imageUrl: String
        let createdAt: String
    }
}

extension ActivityTimelineListResponseDTO {
    func toModel() -> TimeLineData {
        TimeLineData(
            activityId: activityId,
            timelines: timelines.map { $0.toModel() }
        )
    }
}

extension ActivityTimelineListResponseDTO.Timeline {
    func toModel() -> TimeLineItemData {
        TimeLineItemData(
            timelineId: timelineId,
            title: title,
            imageUrl: imageUrl,
            createdAt: createdAt
        )
    }
}
