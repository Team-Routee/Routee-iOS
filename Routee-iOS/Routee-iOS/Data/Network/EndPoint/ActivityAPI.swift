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
    case createTimeLine(header: HeaderType, activityId: Int64, requestDTO: CreateTimeLineRequestDTO)
    case backgroundMapPresignedURL(header: HeaderType, activityId: Int64, requestDTO: BackgroundMapPresignedURLRequestDTO)
    case finishActivity(header: HeaderType, activityId: Int64, requestDTO: FinishActivityRequestDTO)
}

extension ActivityAPI: RouteeEndPoint {

    var basePath: String {
        switch self {
        case .activityRoute,
             .createActivity,
             .timeLinePresignedURL,
             .createTimeLine,
             .backgroundMapPresignedURL,
                .finishActivity:
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
        case .createTimeLine(_, let activityId, _):
            return "/\(activityId)/timeline"
        case .backgroundMapPresignedURL(_, let activityId, _):
            return "/\(activityId)/map-image-url"
        case .finishActivity(_, let activityId, _):
            return "/\(activityId)"
        }
    }

    var method: Alamofire.HTTPMethod {
        switch self {
        case .activityRoute:
            return .get
        case .createActivity, .timeLinePresignedURL, .createTimeLine, .backgroundMapPresignedURL:
            return .post
        case .finishActivity:
            return .put
        }
    }

    var headers: HeaderType {
        switch self {
        case .activityRoute(let header, _),
             .createActivity(let header, _),
             .timeLinePresignedURL(let header, _, _),
             .createTimeLine(let header, _, _),
             .backgroundMapPresignedURL(let header, _, _),
             .finishActivity(let header, _, _):
            return header
        }
    }

    var parameterEncoding: any Alamofire.ParameterEncoding {
        switch self {
        case .activityRoute:
            return URLEncoding.default
        case .createActivity, .timeLinePresignedURL, .createTimeLine, .backgroundMapPresignedURL, .finishActivity:
            return JSONEncoding.default
        }
    }

    var queryParameters: [String: String]? {
        switch self {
        case .activityRoute,
             .createActivity,
             .timeLinePresignedURL,
             .createTimeLine,
             .backgroundMapPresignedURL,
             .finishActivity:
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
        case .createTimeLine(_, _, let requestDTO):
            return requestDTO.asParameters()
        case .backgroundMapPresignedURL(_, _, let requestDTO):
            return requestDTO.asParameters()
        case .finishActivity(_, _, let requestDTO):
            return requestDTO.asParameters()
        }
    }
}
