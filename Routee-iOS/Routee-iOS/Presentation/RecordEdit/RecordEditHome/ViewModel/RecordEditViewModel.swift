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

    init(activityRepository: ActivityRepository = RecordEditActivityRepository.make()) {
        self.activityRepository = activityRepository
    }

    // MARK: - Public Methods

    func fetchWorkoutList(year: Int, month: Int) async throws {
        records = try await activityRepository.getWorkoutList(
            year: year,
            month: month
        )
    }

    func updateWorkoutTitle(
        activityId: Int64,
        title: String
    ) async throws -> UpdateArchiveActivityTitleResponseDTO {
        let requestDTO = UpdateArchiveActivityTitleRequestDTO(title: title)
        let response = try await activityRepository.updateArchiveActivityTitle(
            activityId: activityId,
            requestDTO: requestDTO
        )

        updateRecordTitle(
            activityId: response.activityId,
            title: response.title
        )

        return response
    }

    private func updateRecordTitle(
        activityId: Int64,
        title: String
    ) {
        guard let index = records.firstIndex(where: { $0.activityId == activityId }) else { return }

        let record = records[index]
        records[index] = WorkoutListModel(
            activityId: record.activityId,
            title: title,
            activityDate: record.activityDate,
            timelineImageUrls: record.timelineImageUrls
        )
    }
}
