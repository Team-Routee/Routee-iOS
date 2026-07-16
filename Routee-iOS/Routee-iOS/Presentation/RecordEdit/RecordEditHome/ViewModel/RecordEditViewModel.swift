//
//  RecordEditViewModel.swift
//  Routee-iOS
//
//  Created by 김세령 on 7/15/26.
//

import Foundation

@MainActor
final class RecordEditViewModel {

    // MARK: - Properties

    private let activityRepository: ActivityRepository
    private(set) var records: [WorkoutListModel] = []

    // MARK: - Initializer

    init(activityRepository: ActivityRepository = DefaultActivityRepository()) {
        self.activityRepository = activityRepository
    }

    // MARK: - Public Methods

    func fetchWorkoutList(year: Int, month: Int) async throws {
        records = try await activityRepository.getWorkoutList(
            year: year,
            month: month
        )
    }
}
