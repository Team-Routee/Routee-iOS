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
}

extension ActivityAPI: RouteeEndPoint {

    var basePath: String {
        switch self {
        case .activityRoute, .activityStatistics:
            return "/api/v1/activity"
        }
    }

    var path: String {
        switch self {
        case .activityRoute(_, let activityId):
            return "/\(activityId)/track"
        case .activityStatistics(_, let activityId):
            return "/\(activityId)/statistics"
        }
    }

    var method: Alamofire.HTTPMethod {
        switch self {
        case .activityRoute, .activityStatistics:
            return .get
        }
    }

    var headers: HeaderType {
        switch self {
        case .activityRoute(let header, _):
            return header
        case .activityStatistics(let header, _):
            return header
        }
    }

    var parameterEncoding: any Alamofire.ParameterEncoding {
        switch self {
        case .activityRoute, .activityStatistics:
            return URLEncoding.default
        }
    }

    var queryParameters: [String: String]? {
        switch self {
        case .activityRoute, .activityStatistics:
            return nil
        }
    }

    var bodyParameters: Alamofire.Parameters? {
        switch self {
        case .activityRoute, .activityStatistics:
            return nil
        }
    }
}
