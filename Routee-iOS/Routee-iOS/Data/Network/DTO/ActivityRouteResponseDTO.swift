//
//  ActivityResponseDTO.swift
//  Routee-iOS
//
//  Created by 김세령 on 7/14/26.
//

import Foundation

struct ActivityRouteResponseDTO: Decodable, Sendable {
    let activityId: Int64
    let trackPoints: [TrackPointDTO]
    let timelineMarkers: [TimelineMarkerDTO]
}

struct TrackPointDTO: Decodable, Sendable {
    let latitude: Double
    let longitude: Double
    let elevation: Double
    let pointIndex: Int
}

struct TimelineMarkerDTO: Decodable, Sendable {
    let timelineId: Int64
    let thumbnailUrl: String
    let latitude: Double
    let longitude: Double
    let pointIndex: Int
}
