//
//  TimeLineViewModel.swift
//  Routee-iOS
//
//  Created by 초긍정행운의포춘쿠키 on 7/15/26.
//

import Foundation

struct ActivityStatisticsMetricViewModel {
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

    func fetchActivityStatistics(activityId: Int64) async throws -> ActivityStatisticsMetricViewModel {
        let model = try await activityRepository.getActivityStatistics(activityId: activityId)
        return makeMetricViewModel(from: model)
    }

    func fetchActivityRoute(activityId: Int64) async throws -> [TrackPoint] {
        let model = try await activityRepository.getActivityRoute(activityId: activityId)
        return model.trackPoints
    }

    func fetchTimeLineList(activityId: Int64) async throws -> TimeLineListModel {
        try await activityRepository.getActivityTimelineList(activityId: activityId)
    }

    // MARK: - Private Methods

    private func makeMetricViewModel(
        from model: ActivityStatisticsModel
    ) -> ActivityStatisticsMetricViewModel {
        ActivityStatisticsMetricViewModel(
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
