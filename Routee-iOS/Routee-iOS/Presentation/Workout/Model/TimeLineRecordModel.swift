//
//  TimeLineRecordModel.swift
//  Routee-iOS
//
//  Created by LEESANGYUP on 7/16/26.
//

import Foundation

struct TimeLineRecordModel {
    let title: String
    let imageObjectKey: String
    let createdAt: String
    let trackPointIndex: Int
    let locations: [Location]
    let status: String

    struct Location {
        let latitude: Double
        let longitude: Double
        let elevation: Int
        let pointIndex: Int
    }
}

extension TimeLineRecordModel {
    func toDTO() -> CreateTimeLineRequestDTO {
        CreateTimeLineRequestDTO(
            title: title,
            timelineImageObjectKey: imageObjectKey,
            createdAt: createdAt,
            trackPointIndex: trackPointIndex,
            location: locations.map {
                LocationData(
                    latitude: $0.latitude,
                    longitude: $0.longitude,
                    elevation: $0.elevation,
                    pointIndex: $0.pointIndex
                )
            },
            status: status
        )
    }
}
