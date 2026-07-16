//
//  CreateCourseListRequestDTO.swift
//  Routee-iOS
//
//  Created by LEESANGYUP on 7/16/26.
//

import Foundation

struct CreateCourseListRequestDTO: Encodable {
    let routes: [RouteData]
}

struct RouteData: Codable {
    let routeId: Int64
    let name: String
    let sequence: Int
}
