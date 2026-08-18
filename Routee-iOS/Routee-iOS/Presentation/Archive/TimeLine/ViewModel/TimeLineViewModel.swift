//
//  TimeLineViewModel.swift
//  Routee-iOS
//
//  Created by 초긍정행운의포춘쿠키 on 7/15/26.
//

import Foundation

struct TimeLineMetricViewModel {
    let distance: String
    let time: String
    let altitude: String
}

final class TimeLineViewModel {

    // MARK: - Properties

    private let activityRepository: ActivityRepository

    // MARK: - Initializer

    init(activityRepository: ActivityRepository = DefaultActivityRepository()) {
        self.activityRepository = activityRepository
    }

    // MARK: - Public Methods

    func fetchActivityStatistics(activityId: Int64) async throws -> TimeLineMetricViewModel {
        let model = try await activityRepository.getActivityStatistics(activityId: activityId)
        return makeMetricViewModel(from: model)
    }

    func fetchActivityRoute(activityId: Int64) async throws -> ActivityEditorModel {
        try await activityRepository.getActivityRoute(activityId: activityId)
    }

    func fetchTimeLineList(activityId: Int64) async throws -> TimeLineData {
        try await activityRepository.getActivityTimelineList(activityId: activityId)
    }

    func fetchCourseList(activityId: Int64) async throws -> CourseData {
        try await activityRepository.getActivityCourseList(activityId: activityId)
    }

    func updateArchiveActivityTitle(activityId: Int64, title: String) async throws -> UpdateArchiveActivityTitleResponseDTO {
        let requestDTO = UpdateArchiveActivityTitleRequestDTO(title: title)
        return try await activityRepository.updateArchiveActivityTitle(
            activityId: activityId,
            requestDTO: requestDTO
        )
    }

    // MARK: - Private Methods

    private func makeMetricViewModel(
        from model: TimeLineMetricModel
    ) -> TimeLineMetricViewModel {
        TimeLineMetricViewModel(
            distance: formattedDistance(meter: model.distanceMeter),
            time: formattedDuration(seconds: model.durationSec),
            altitude: "\(model.maxElevationMeter)"
        )
    }

    private func formattedDistance(meter: Int) -> String {
        String(format: "%.2f", Double(meter) / 1000)
    }

    private func formattedDuration(seconds: Int) -> String {
        let totalMinutes = seconds / 60
        let hours = totalMinutes / 60
        let minutes = totalMinutes % 60

        return String(format: "%02d:%02d", hours, minutes)
    }
}
