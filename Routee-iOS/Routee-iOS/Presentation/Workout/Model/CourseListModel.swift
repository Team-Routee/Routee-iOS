//
//  CourseListModel.swift
//  Routee-iOS
//
//  Created by LEESANGYUP on 7/16/26.
//

import Foundation

struct CourseListModel {
    let activityId: Int64
    let routes: [RouteData]

    struct RouteData {
        let routeId: Int64
        let name: String
        let sequence: Int
    }
}
