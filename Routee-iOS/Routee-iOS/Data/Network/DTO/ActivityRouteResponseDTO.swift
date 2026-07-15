//
//  ActivityResponseDTO.swift
//  Routee-iOS
//
//  Created by 김세령 on 7/14/26.
//

import Foundation

struct ActivityRouteResponseDTO: Decodable, Sendable {
    let activityId: Int64
    let trackPoints: [TrackPoints]
    let timelineMarkers: [TimelineMarker]
}

struct TrackPoints: Decodable, Sendable {
    let latitude: Double
    let longitude: Double
    let elevation: Double
    let pointIndex: Int
}

struct TimelineMarker: Decodable, Sendable {
    let timelineId: Int64
    let thumbnailUrl: String
    let latitude: Double
    let longitude: Double
    let pointIndex: Int
}

extension ActivityRouteResponseDTO {
    func toModel() -> ActivityEditorModel {
        ActivityEditorModel(
            activityId: activityId,
            trackPoints: trackPoints.map { $0.toModel() },
            pointIndices: timelineMarkers.map(\.pointIndex),
            timelineMarkers: timelineMarkers.map { $0.toModel() }
        )
    }
}

extension TrackPoints {
    func toModel() -> TrackPoint {
        TrackPoint(
            latitude: latitude,
            longitude: longitude
        )
    }
}

extension TimelineMarker {
    func toModel() -> TimeLineMarkerModel {
        TimeLineMarkerModel(
            timelineId: timelineId,
            thumbnailUrl: thumbnailUrl,
            latitude: latitude,
            longitude: longitude,
            pointIndex: pointIndex
        )
    }
}
