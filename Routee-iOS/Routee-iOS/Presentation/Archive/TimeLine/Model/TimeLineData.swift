//
//  TimeLineData.swift
//  Routee-iOS
//
//  Created by 초긍정행운의포춘쿠키 on 7/15/26.
//

import Foundation

struct TimeLineData {
    let activityId: Int64
    let timelines: [TimeLineItemData]
}

struct TimeLineItemData {
    let timelineId: Int64
    let title: String
    let imageUrl: String
    let createdAt: String
}

extension TimeLineData {
    var imageUrls: [String] {
        timelines.map(\.imageUrl)
    }

    var locations: [String?] {
        timelines.map(\.title)
    }
}
