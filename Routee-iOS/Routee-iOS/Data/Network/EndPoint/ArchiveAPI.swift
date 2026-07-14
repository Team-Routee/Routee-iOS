//
//  ArchiveAPI.swift
//  Routee-iOS
//
//  Created by 초긍정행운의포춘쿠키 on 7/14/26.
//

import Foundation

import Alamofire

enum ArchiveAPI {
    case activitySummary(header: HeaderType, requestDTO: ActivitySummaryRequestDTO)
}

extension ArchiveAPI: RouteeEndPoint {
    var basePath: String {
        switch self {
        case .activitySummary:
            "/api/v1/archive"
        }
    }
    
    var path: String {
        switch self {
        case .activitySummary:
            return "/activity-summary"
        }
    }
    
    var method: Alamofire.HTTPMethod {
        switch self {
        case .activitySummary:
            return .get
        }
    }
    
    var headers: HeaderType {
        switch self {
        case .activitySummary(let header, _):
            return header
        }
    }
    
    var parameterEncoding: any Alamofire.ParameterEncoding {
        switch self {
        case .activitySummary:
            return URLEncoding.default
        }
    }
    
    var queryParameters: [String: String]? {
        switch self {
        case .activitySummary(_, let requestDTO):
            [
                "year": "\(requestDTO.year)",
                "month": "\(requestDTO.month)"
            ]
        }
    }
    
    var bodyParameters: Alamofire.Parameters? {
        switch self {
        case .activitySummary:
            nil
        }
    }
}
