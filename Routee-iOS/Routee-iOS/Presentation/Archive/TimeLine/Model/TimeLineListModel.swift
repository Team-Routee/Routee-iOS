//
//  TimeLineListModel.swift
//  Routee-iOS
//
//  Created by 초긍정행운의포춘쿠키 on 7/15/26.
//

import Foundation

struct TimeLineListModel {
    let activityId: Int64
    let timelines: [TimeLineModel]
}

struct TimeLineModel {
    let timelineId: Int64
    let title: String
    let imageUrl: String
    let createdAt: String
}

extension TimeLineListModel {
    var imageUrls: [String] {
        timelines.map(\.imageUrl)
    }

    var locations: [String?] {
        timelines.map(\.title)
    }
}
