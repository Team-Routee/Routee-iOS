//
//  WorkoutRecordFinishModel.swift
//  Routee-iOS
//
//  Created by LEESANGYUP on 7/16/26.
//

import Foundation

struct WorkoutRecordFinishModel {
    let title: String
    let distance: Int
    let durationSec: Int
    let maxAltitude: Int
    let mapImageObjectKey: String
    let tracks: [Track]
    let endedAt: String

    struct Track {
        let latitude: Double
        let longitude: Double
        let elevation: Int
        let pointIndex: Int
    }
}

extension WorkoutRecordFinishModel {
    func toDTO() -> FinishActivityRequestDTO {
        FinishActivityRequestDTO(
            title: title,
            distance: distance,
            durationSec: durationSec,
            maxElevation: maxAltitude,
            mapImageObjectKey: mapImageObjectKey,
            track: tracks.map {
                TrackData(
                    latitude: $0.latitude,
                    longitude: $0.longitude,
                    elevation: $0.elevation,
                    pointIndex: $0.pointIndex
                )
            },
            endedAt: endedAt
        )
    }
}
