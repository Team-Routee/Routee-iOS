//
//  WorkoutListResponseDTO.swift
//  Routee-iOS
//
//  Created by 김세령 on 7/15/26.
//

import Foundation

struct WorkoutListResponseDTO: Decodable, Sendable {
    let year: Int
    let month: Int
    let activities: [Activity]
}

struct Activity: Decodable, Sendable {
    let activityId: Int64
    let title: String
    let activityDate: String
    let timelineImageUrls: [String]
}

extension WorkoutListResponseDTO {
    func toModel() -> [WorkoutListModel] {
        activities.map { $0.toModel() }
    }
}

extension Activity {
    func toModel() -> WorkoutListModel {
        WorkoutListModel(
            activityId: activityId,
            title: title,
            activityDate: activityDate,
            timelineImageUrls: timelineImageUrls
        )
    }
}
