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
    let coverImageObjectKey: String?
    let track: [TrackData]
    let endedAt: String

    private enum CodingKeys: String, CodingKey {
        case title
        case distance
        case durationSec
        case maxElevation
        case mapImageUrl
        case coverImageObjectKey
        case track
        case endedAt
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(title, forKey: .title)
        try container.encode(distance, forKey: .distance)
        try container.encode(durationSec, forKey: .durationSec)
        try container.encode(maxElevation, forKey: .maxElevation)
        try container.encode(mapImageUrl, forKey: .mapImageUrl)
        if let coverImageObjectKey {
            try container.encode(coverImageObjectKey, forKey: .coverImageObjectKey)
        } else {
            try container.encodeNil(forKey: .coverImageObjectKey)
        }
        try container.encode(track, forKey: .track)
        try container.encode(endedAt, forKey: .endedAt)
    }
}

struct TrackData: Encodable {
    let latitude: Double
    let longitude: Double
    let elevation: Int
    let pointIndex: Int
}
