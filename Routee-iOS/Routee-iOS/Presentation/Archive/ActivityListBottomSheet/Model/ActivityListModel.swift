//
//  ActivityListModel.swift
//  Routee-iOS
//

import Foundation

struct ActivityListDateModel {
    let dateText: String
    let items: [ActivityListModel]
}

struct ActivityListModel {
    let activityId: Int64
    let title: String
    let thumbnailUrl: String?
}
