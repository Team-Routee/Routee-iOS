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
