//
//  ActivityStatisticsResponseDTO.swift
//  Routee-iOS
//

import Foundation

struct ActivityStatisticsResponseDTO: Decodable, Sendable {
    let activityId: Int64
    let title: String
    let activityDate: String
    let distanceMeter: Int
    let durationSec: Int
    let maxElevationMeter: Int
}

extension ActivityStatisticsResponseDTO {
    func toModel() -> TimeLineMetricModel {
        TimeLineMetricModel(
            activityId: activityId,
            title: title,
            activityDate: activityDate,
            distanceMeter: distanceMeter,
            durationSec: durationSec,
            maxElevationMeter: maxElevationMeter
        )
    }
}
