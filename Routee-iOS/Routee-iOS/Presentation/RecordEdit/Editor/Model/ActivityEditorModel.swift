//
//  ActivityEditorModel.swift
//  Routee-iOS
//
//  Created by 김세령 on 7/15/26.
//

import Foundation

struct ActivityEditorModel {
    let activityId: Int64
    let trackPoints: [TrackPoint]
    let pointIndices: [Int]
}

extension ActivityRouteResponseDTO {
    func toEditorModel() -> ActivityEditorModel {
        ActivityEditorModel(
            activityId: activityId,
            trackPoints: trackPoints.map { $0.toModel() },
            pointIndices: timelineMarkers.map(\.pointIndex)
        )
    }
}

extension TrackPointDTO {
    func toModel() -> TrackPoint {
        TrackPoint(
            latitude: latitude,
            longitude: longitude
        )
    }
}
