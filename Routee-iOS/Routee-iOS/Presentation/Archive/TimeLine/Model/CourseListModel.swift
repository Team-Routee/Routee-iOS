//
//  CourseListModel.swift
//  Routee-iOS
//
//  Created by 초긍정행운의포춘쿠키 on 7/15/26.
//

import Foundation

struct CourseListModel {
    let activityId: Int64
    let courses: [CourseModel]
}

struct CourseModel {
    let routeId: Int64
    let name: String
    let sequence: Int
}

extension CourseListModel {
    var routePoint: RoutePointModel {
        RoutePointModel(
            points: courses
                .sorted { $0.sequence < $1.sequence }
                .map(\.name)
        )
    }
}
