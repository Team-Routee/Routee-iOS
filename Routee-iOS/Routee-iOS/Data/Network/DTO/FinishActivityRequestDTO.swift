//
//  FinishActivityRequestDTO.swift
//  Routee-iOS
//
//  Created by LEESANGYUP on 7/16/26.
//

import Foundation

struct FinishActivityRequestDTO: Encodable {
    let title: String
    let distance: Int
    let durationSec: Int
    let maxElevation: Int
    let mapImageUrl: String
    let coverImageObjectKey: String
    let track: [TrackData]
    let endedAt: String
}

struct TrackData: Encodable {
    let latitude: Double
    let longitude: Double
    let elevation: Int
    let pointIndex: Int
}
