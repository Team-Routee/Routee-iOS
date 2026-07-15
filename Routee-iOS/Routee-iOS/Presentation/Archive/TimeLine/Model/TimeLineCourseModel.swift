//
//  TimeLineCourseModel.swift
//  Routee-iOS
//
//  Created by 초긍정행운의포춘쿠키 on 7/15/26.
//

import Foundation

struct TimeLineCourseModel {
    let activityId: Int64
    let courses: [TimeLineCourseItemModel]
}

struct TimeLineCourseItemModel {
    let routeId: Int64
    let name: String
    let sequence: Int
}

extension TimeLineCourseModel {
    var routePoint: RoutePointModel {
        RoutePointModel(
            points: courses
                .sorted { $0.sequence < $1.sequence }
                .map(\.name)
        )
    }
}
