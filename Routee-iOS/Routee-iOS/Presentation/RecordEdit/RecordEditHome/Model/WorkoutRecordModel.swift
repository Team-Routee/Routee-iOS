//
//  WorkoutRecordModel.swift
//  Routee-iOS
//
//  Created by 김세령 on 7/7/26.
//

import Foundation

struct WorkoutRecordModel {
    let title: String
    let date: Date
    let imageNames: [String]
    
    init(
        title: String,
        date: Date,
        imageNames: [String] = []
    ) {
        self.title = title
        self.date = date
        self.imageNames = Array(imageNames.prefix(4))
    }
}
