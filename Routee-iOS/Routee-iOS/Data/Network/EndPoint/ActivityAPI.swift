//
//  ActivityAPI.swift
//  Routee-iOS
//
//  Created by 김세령 on 7/14/26.
//

import Foundation

import Alamofire

enum ActivityAPI {
    case activityRoute(header: HeaderType, activityId: Int64)
    case activityStatistics(header: HeaderType, activityId: Int64)
    case activityTimelineList(header: HeaderType, activityId: Int64)
    case activityCourseList(header: HeaderType, activityId: Int64)
    case recordEditResource(header: HeaderType, activityId: Int64)
    case workoutList(header: HeaderType, requestDTO: WorkoutListRequestDTO)
}

extension ActivityAPI: RouteeEndPoint {

    var basePath: String {
        switch self {
        case .activityRoute, .recordEditResource, .workoutList,  .activityStatistics, .activityTimelineList, .activityCourseList:
            return "/api/v1/activity"
        }
    }

    var path: String {
        switch self {
        case .activityRoute(_, let activityId):
            return "/\(activityId)/track"
        case .activityStatistics(_, let activityId):
            return "/\(activityId)/statistics"
        case .activityTimelineList(_, let activityId):
            return "/\(activityId)/timeline"
        case .activityCourseList(_, let activityId):
            return "/\(activityId)/route"
        case .recordEditResource(_, let activityId):
            return "/\(activityId)/recap"
        case .workoutList:
            return "/recap"
        }
    }

    var method: Alamofire.HTTPMethod {
        switch self {
        case .activityRoute, .activityStatistics, .activityTimelineList, .activityCourseList, .recordEditResource, .workoutList:
            return .get
        }
    }

    var headers: HeaderType {
        switch self {
        case .activityRoute(let header, _):
            return header
        case .activityStatistics(let header, _):
            return header
        case .activityTimelineList(let header, _):
            return header
        case .activityCourseList(let header, _):
            return header
        case .recordEditResource(let header, _):
            return header
        case .workoutList(let header, _):
            return header
        }
    }

    var parameterEncoding: any Alamofire.ParameterEncoding {
        switch self {
        case .activityRoute, .activityStatistics, .activityTimelineList, .activityCourseList, .recordEditResource, .workoutList:
            return URLEncoding.default
        }
    }

    var queryParameters: [String: String]? {
        switch self {
        case .activityRoute, .activityStatistics, .activityTimelineList, .activityCourseList, .recordEditResource:
            return nil
        case .workoutList(_, let requestDTO):
            return [
                "year": "\(requestDTO.year)",
                "month": "\(requestDTO.month)"
            ]
        }
    }

    var bodyParameters: Alamofire.Parameters? {
        switch self {
        case .activityRoute, .activityStatistics, .activityTimelineList, .activityCourseList, .recordEditResource, .workoutList:
            return nil
        }
    }
}
