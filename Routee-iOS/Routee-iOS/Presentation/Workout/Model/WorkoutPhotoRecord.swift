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
    let createdAt: Date = Date()
    var locationTitle: String?
    var objectKey: String?
    var timelineId: Int64?
}
