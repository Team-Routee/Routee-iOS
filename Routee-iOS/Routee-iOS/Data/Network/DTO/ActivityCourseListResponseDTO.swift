//
//  ActivityCourseListResponseDTO.swift
//  Routee-iOS
//
//  Created by 초긍정행운의포춘쿠키 on 7/15/26.
//

import Foundation

struct ActivityCourseListResponseDTO: Decodable, Sendable {
    let activityId: Int64
    let routes: [Route]

    struct Route: Decodable, Sendable {
        let routeId: Int64
        let name: String
        let sequence: Int
    }
}

extension ActivityCourseListResponseDTO {
    func toModel() -> TimeLineCourseModel {
        TimeLineCourseModel(
            activityId: activityId,
            courses: routes.map { $0.toModel() }
        )
    }
}

extension ActivityCourseListResponseDTO.Route {
    func toModel() -> TimeLineCourseItemModel {
        TimeLineCourseItemModel(
            routeId: routeId,
            name: name,
            sequence: sequence
        )
    }
}
