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
}

extension ActivityAPI: RouteeEndPoint {

    var basePath: String {
        switch self {
        case .activityRoute, .recordEditResource:
            return "/api/v1/activity"
        }
    }

    var path: String {
        switch self {
        case .activityRoute(_, let activityId):
            return "/\(activityId)/track"
        case .recordEditResource(_, let activityId):
            return "/\(activityId)/recap"
        }
    }

    var method: Alamofire.HTTPMethod {
        switch self {
        case .activityRoute, .recordEditResource:
            return .get
        }
    }

    var headers: HeaderType {
        switch self {
        case .activityRoute(let header, _):
            return header
        case .recordEditResource(let header, _):
            return header
        }
    }

    var parameterEncoding: any Alamofire.ParameterEncoding {
        switch self {
        case .activityRoute, .recordEditResource:
            return URLEncoding.default
        }
    }

    var queryParameters: [String: String]? {
        switch self {
        case .activityRoute, .recordEditResource:
            return nil
        }
    }

    var bodyParameters: Alamofire.Parameters? {
        switch self {
        case .activityRoute, .recordEditResource:
            return nil
        }
    }
}
