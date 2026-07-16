//
//  CreateCourseListResponseDTO.swift
//  Routee-iOS
//
//  Created by LEESANGYUP on 7/16/26.
//

import Foundation

struct CreateCourseListResponseDTO: Decodable, Sendable {
    let activityId: Int64
    let routes: [RouteData]
}

extension CreateCourseListResponseDTO {
    func toModel() -> CourseListModel {
        CourseListModel(
            activityId: activityId,
            routes: routes.map {
                CourseListModel.Route(
                    routeId: $0.routeId,
                    name: $0.name,
                    sequence: $0.sequence
                )
            }
        )
    }
}
