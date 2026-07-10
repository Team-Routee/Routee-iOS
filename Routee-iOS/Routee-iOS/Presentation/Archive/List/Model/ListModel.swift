//
//  ListModel.swift
//  Routee-iOS
//

import Foundation

struct ListItemModel {
    let activityId: Int
    let title: String
    let thumbnailUrl: String?
}

struct ListModel {
    let dateText: String
    let items: [ListItemModel]
}
