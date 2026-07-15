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
    case createActivity(header: HeaderType, requestDTO: ActivityCreateRequestDTO)
    case timeLinePresignedURL(header: HeaderType, activityId: Int64, requestDTO: TimeLinePresignedURLRequestDTO)
}

extension ActivityAPI: RouteeEndPoint {

    var basePath: String {
        switch self {
        case .activityRoute, .createActivity, .timeLinePresignedURL:
            return "/api/v1/activity"
        }
    }

    var path: String {
        switch self {
        case .activityRoute(_, let activityId):
            return "/\(activityId)/track"
        case .createActivity:
            return ""
        case .timeLinePresignedURL(_, let activityId, _):
            return "/\(activityId)/image-url"
        }
    }

    var method: Alamofire.HTTPMethod {
        switch self {
        case .activityRoute:
            return .get
        case .createActivity, .timeLinePresignedURL:
            return .post
        }
    }

    var headers: HeaderType {
        switch self {
        case .activityRoute(let header, _), .createActivity(let header, _), .timeLinePresignedURL(let header, _, _):
            return header
        }
    }

    var parameterEncoding: any Alamofire.ParameterEncoding {
        switch self {
        case .activityRoute:
            return URLEncoding.default
        case .createActivity:
            return JSONEncoding.default
        case .timeLinePresignedURL:
            return JSONEncoding.default
        }
    }

    var queryParameters: [String: String]? {
        switch self {
        case .activityRoute, .createActivity, .timeLinePresignedURL:
            return nil
        }
    }

    var bodyParameters: Alamofire.Parameters? {
        switch self {
        case .activityRoute:
            return nil
        case .createActivity(_, let requestDTO):
            return requestDTO.asParameters()
        case .timeLinePresignedURL(_, _, let requestDTO):
            return requestDTO.asParameters()
        }
    }
}
