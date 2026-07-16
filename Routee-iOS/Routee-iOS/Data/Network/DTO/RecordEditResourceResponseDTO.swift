//
//  RecordEditResourceResponseDTO.swift
//  Routee-iOS
//
//  Created by 김세령 on 7/15/26.
//

import Foundation

struct RecordEditResourceResponseDTO: Decodable, Sendable {
    let distance: Int
    let durationSec: Int
    let maxElevation: Int
    let mapImageUrl: String
    let routes: [RecordEditRouteResponse]
}

struct RecordEditRouteResponse: Decodable, Sendable {
    let sequence: Int
    let name: String
}

extension RecordEditResourceResponseDTO {
    func toModel() -> RecordEditResourceModel {
        RecordEditResourceModel(
            distance: distance,
            durationSec: durationSec,
            maxElevation: maxElevation,
            mapImageURL: mapImageUrl,
            routes: routes.map { $0.toModel() }
        )
    }
}

extension RecordEditRouteResponse {
    func toModel() -> RecordEditRoute {
        RecordEditRoute(
            sequence: sequence,
            name: name
        )
    }
}
