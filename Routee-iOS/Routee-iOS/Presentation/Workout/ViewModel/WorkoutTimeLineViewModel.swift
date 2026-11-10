//
//  WorkoutTimeLineViewModel.swift
//  Routee-iOS
//
//  Created by LEESANGYUP on 11/10/26.
//

import Foundation

@MainActor
final class WorkoutTimeLineViewModel {
    private let activityRepository: ActivityRepository

    init(activityRepository: ActivityRepository) {
        self.activityRepository = activityRepository
    }

    func deleteActivity(activityId: Int64) async throws {
        try await activityRepository.deleteActivity(activityId: activityId)
    }
}
