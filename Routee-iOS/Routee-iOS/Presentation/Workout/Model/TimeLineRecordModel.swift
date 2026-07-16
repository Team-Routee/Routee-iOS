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
    let location: Location
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
            location: LocationData(
                latitude: location.latitude,
                longitude: location.longitude,
                elevation: location.elevation,
                pointIndex: location.pointIndex
            ),
            status: status
        )
    }
}
