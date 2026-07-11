//
//  DailyRecordModel.swift
//  Routee-iOS
//

import Foundation

struct DailyRecordModel {
    let activityId: Int
    let title: String
    let thumbnailUrl: String?
}

struct CalendarDateModel {
    let dateText: String
    let items: [DailyRecordModel]
}
