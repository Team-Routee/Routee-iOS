//
//  ActivityListResponseDTO.swift
//  Routee-iOS
//

import Foundation

struct ActivityListResponseDTO: Decodable, Sendable {
    let date: String
    let activities: [Activity]

    struct Activity: Decodable, Sendable {
        let activityId: Int
        let title: String
        let thumbnailUrl: String?
    }
}

extension ActivityListResponseDTO {
    func toModel() -> ActivityListDateModel {
        ActivityListDateModel(
            dateText: date.replacingOccurrences(of: "-", with: "."),
            items: activities.map {
                ActivityListModel(
                    activityId: $0.activityId,
                    title: $0.title,
                    thumbnailUrl: $0.thumbnailUrl
                )
            }
        )
    }
}
