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
    case createActivity(header: HeaderType, requestDTO: ActivityCreateRequestDTO)
    case timeLinePresignedURL(header: HeaderType, activityId: Int64, requestDTO: TimeLinePresignedURLRequestDTO)
    case createTimeLine(header: HeaderType, activityId: Int64, requestDTO: CreateTimeLineRequestDTO)
    case deleteTimeline(header: HeaderType, activityId: Int64, timelineId: Int64)
    case backgroundMapPresignedURL(header: HeaderType, activityId: Int64, requestDTO: BackgroundMapPresignedURLRequestDTO)
    case finishActivity(header: HeaderType, activityId: Int64, requestDTO: FinishActivityRequestDTO)
    case changeActivityStatus(header: HeaderType, activityId: Int64, requestDTO: ChangeActivityStatusRequestDTO)
    case updateArchiveActivityTitle(header: HeaderType, activityId: Int64, requestDTO: UpdateArchiveActivityTitleRequestDTO)
    case createCourseList(header: HeaderType, activityId: Int64, requestDTO: CreateCourseListRequestDTO)
}

extension ActivityAPI: RouteeEndPoint {
    
    var basePath: String {
        switch self {
        case .activityRoute,
             .recordEditResource,
             .workoutList,
             .activityStatistics,
             .activityTimelineList,
             .activityCourseList,
             .createActivity,
             .timeLinePresignedURL,
             .createTimeLine,
             .deleteTimeline,
             .backgroundMapPresignedURL,
             .finishActivity,
             .changeActivityStatus,
             .updateArchiveActivityTitle,
             .createCourseList:
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
        case .createActivity:
            return ""
        case .timeLinePresignedURL(_, let activityId, _):
            return "/\(activityId)/image-url"
        case .createTimeLine(_, let activityId, _):
            return "/\(activityId)/timeline"
        case .deleteTimeline(_, let activityId, let timelineId):
            return "/\(activityId)/timeline/\(timelineId)"
        case .backgroundMapPresignedURL(_, let activityId, _):
            return "/\(activityId)/map-image-url"
        case .finishActivity(_, let activityId, _):
            return "/\(activityId)"
        case .changeActivityStatus(_, let activityId, _):
            return "/\(activityId)/status"
        case .updateArchiveActivityTitle(_, let activityId, _):
            return "/\(activityId)/title"
        case .createCourseList(_, let activityId, _):
            return "/\(activityId)/route"
        }
    }
    
    var method: Alamofire.HTTPMethod {
        switch self {
        case .activityRoute, .activityStatistics, .activityTimelineList, .activityCourseList, .recordEditResource, .workoutList:
            return .get
        case .createActivity, .timeLinePresignedURL, .createTimeLine, .backgroundMapPresignedURL, .createCourseList:
            return .post
        case .finishActivity:
            return .put
        case .changeActivityStatus, .updateArchiveActivityTitle:
            return .patch
        case .deleteTimeline:
            return .delete
        }
    }
    
    var headers: HeaderType {
        switch self {
        case .activityRoute(let header, _),
                .createActivity(let header, _),
                .timeLinePresignedURL(let header, _, _),
                .createTimeLine(let header, _, _),
                .deleteTimeline(let header, _, _),
                .backgroundMapPresignedURL(let header, _, _),
                .finishActivity(let header, _, _),
                .changeActivityStatus(let header, _, _),
                .updateArchiveActivityTitle(let header, _, _),
                .createCourseList(let header, _, _):
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
        case .activityRoute,
                .activityStatistics,
                .activityTimelineList,
                .activityCourseList,
                .recordEditResource,
                .workoutList,
                .deleteTimeline:
            return URLEncoding.default
        case .createActivity,
                .timeLinePresignedURL,
                .createTimeLine,
                .backgroundMapPresignedURL,
                .finishActivity,
                .changeActivityStatus,
                .updateArchiveActivityTitle,
                .createCourseList:
            return JSONEncoding.default
        }
    }
    
    var queryParameters: [String: String]? {
        switch self {
        case .activityRoute,
             .activityStatistics,
             .activityTimelineList,
             .activityCourseList,
             .recordEditResource,
             .createActivity,
             .timeLinePresignedURL,
             .createTimeLine,
             .deleteTimeline,
             .backgroundMapPresignedURL,
             .finishActivity,
             .changeActivityStatus,
             .updateArchiveActivityTitle,
             .createCourseList:
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
        case .activityRoute,
                .activityStatistics,
                .activityTimelineList,
                .activityCourseList,
                .recordEditResource,
                .workoutList,
                .deleteTimeline:
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
        case .changeActivityStatus(_, _, let requestDTO):
            return requestDTO.asParameters()
        case .updateArchiveActivityTitle(_, _, let requestDTO):
            return requestDTO.asParameters()
        case .createCourseList(_, _, let requestDTO):
            return requestDTO.asParameters()
        }
    }
}
