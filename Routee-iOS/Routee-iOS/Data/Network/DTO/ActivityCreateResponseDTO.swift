//
//  ActivityCreateResponseDTO.swift
//  Routee-iOS
//
//  Created by LEESANGYUP on 7/15/26.
//

import Foundation

struct ActivityCreateResponseDTO: Decodable, Sendable {
    let activityId: Int64
    let title: String
}

extension ActivityCreateResponseDTO {
    func toWorkoutRecordStartModel() -> WorkoutRecordStartModel {
        WorkoutRecordStartModel(activityId: activityId, title: title)
    }
}
