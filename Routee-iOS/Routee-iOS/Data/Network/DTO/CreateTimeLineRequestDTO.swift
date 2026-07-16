//
//  CreateTimeLineRequestDTO.swift
//  Routee-iOS
//
//  Created by LEESANGYUP on 7/16/26.
//

import Foundation

struct CreateTimeLineRequestDTO: Encodable {
    let title: String
    let timelineImageObjectKey: String
    let createdAt: String
    let trackPointIndex: Int
    let location: [LocationData]
    let status: String
}

struct LocationData: Encodable {
    let latitude: Double
    let longitude: Double
    let elevation: Int
    let pointIndex: Int
}
