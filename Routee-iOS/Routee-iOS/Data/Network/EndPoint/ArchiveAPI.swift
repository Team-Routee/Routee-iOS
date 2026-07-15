//
//  ArchiveAPI.swift
//  Routee-iOS
//
//  Created by 초긍정행운의포춘쿠키 on 7/14/26.
//

import Foundation

import Alamofire

enum ArchiveAPI {
    case getArchive(header: HeaderType, requestDTO: ActivitySummaryRequestDTO)
    case getActivityList(header: HeaderType, requestDTO: ActivityListRequestDTO)
}

extension ArchiveAPI: RouteeEndPoint {
    var basePath: String {
        switch self {
        case .getArchive, .getActivityList:
            "/api/v1/archive"
        }
    }
    
    var path: String {
        switch self {
        case .getArchive:
            return "/activity-summary"
        case .getActivityList:
            return "/activity"
        }
    }
    
    var method: Alamofire.HTTPMethod {
        switch self {
        case .getArchive, .getActivityList:
            return .get
        }
    }
    
    var headers: HeaderType {
        switch self {
        case .getArchive(let header, _):
            return header
        case .getActivityList(let header, _):
            return header
        }
    }
    
    var parameterEncoding: any Alamofire.ParameterEncoding {
        switch self {
        case .getArchive, .getActivityList:
            return URLEncoding.default
        }
    }
    
    var queryParameters: [String: String]? {
        switch self {
        case .getArchive(_, let requestDTO):
            [
                "year": "\(requestDTO.year)",
                "month": "\(requestDTO.month)"
            ]
        case .getActivityList(_, let requestDTO):
            [
                "date": requestDTO.date
            ]
        }
    }
    
    var bodyParameters: Alamofire.Parameters? {
        switch self {
        case .getArchive, .getActivityList:
            nil
        }
    }
}
