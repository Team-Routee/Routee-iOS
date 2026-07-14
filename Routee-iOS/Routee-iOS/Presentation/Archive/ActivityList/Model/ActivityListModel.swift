//
//  ActivityListModel.swift
//  Routee-iOS
//

import Foundation

struct ActivityListModel {
    let activityId: Int
    let title: String
    let thumbnailUrl: String?
}

struct ActivityListDateModel {
    let dateText: String
    let items: [ActivityListModel]
}
