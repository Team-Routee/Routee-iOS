//
//  WorkoutPhotoRecord.swift
//  Routee-iOS
//
//  Created by LEESANGYUP on 7/15/26.
//

import UIKit

struct WorkoutPhotoRecord {
    let image: UIImage
    let pointIndex: Int
    let createdAt: Date
    let recoveryId: UUID
    var locationTitle: String?
    var objectKey: String?
    var timelineId: Int64?

    init(
        image: UIImage,
        pointIndex: Int,
        createdAt: Date = Date(),
        recoveryId: UUID = UUID(),
        locationTitle: String? = nil,
        objectKey: String? = nil,
        timelineId: Int64? = nil
    ) {
        self.image = image
        self.pointIndex = pointIndex
        self.createdAt = createdAt
        self.recoveryId = recoveryId
        self.locationTitle = locationTitle
        self.objectKey = objectKey
        self.timelineId = timelineId
    }
}
