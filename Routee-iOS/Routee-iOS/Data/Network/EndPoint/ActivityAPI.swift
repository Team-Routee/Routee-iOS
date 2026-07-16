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
    case recordEditResource(header: HeaderType, activityId: Int64)
    case workoutList(header: HeaderType, requestDTO: WorkoutListRequestDTO)
}

extension ActivityAPI: RouteeEndPoint {

    var basePath: String {
        switch self {
        case .activityRoute, .recordEditResource, .workoutList:
            return "/api/v1/activity"
        }
    }

    var path: String {
        switch self {
        case .activityRoute(_, let activityId):
            return "/\(activityId)/track"
        case .recordEditResource(_, let activityId):
            return "/\(activityId)/recap"
        case .workoutList:
            return "/recap"
        }
    }

    var method: Alamofire.HTTPMethod {
        switch self {
        case .activityRoute, .recordEditResource, .workoutList:
            return .get
        }
    }

    var headers: HeaderType {
        switch self {
        case .activityRoute(let header, _):
            return header
        case .recordEditResource(let header, _):
            return header
        case .workoutList(let header, _):
            return header
        }
    }

    var parameterEncoding: any Alamofire.ParameterEncoding {
        switch self {
        case .activityRoute, .recordEditResource, .workoutList:
            return URLEncoding.default
        }
    }

    var queryParameters: [String: String]? {
        switch self {
        case .activityRoute, .recordEditResource:
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
        case .activityRoute, .recordEditResource, .workoutList:
            return nil
        }
    }
}
