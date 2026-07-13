//
//  MemberAPI.swift
//  Routee-iOS
//
//  Created by LEESANGYUP on 7/13/26.
//

import Foundation

import Alamofire

enum MemberAPI {
    case register(header: HeaderType, requestDTO: RegisterRequestDTO)
    case withdraw(header: HeaderType)
}

extension MemberAPI: RouteeEndPoint {
    var basePath: String {
        switch self {
        case .register, .withdraw:
            return "/api/v1/member"
        }
    }
    
    var path: String {
        switch self{
        case .register:
            return "/register"
        case .withdraw:
            return "/withdraw"
        }
    }
    
    var method: Alamofire.HTTPMethod {
        switch self {
        case .register:
            return  .post
        case .withdraw:
            return .delete
        }
    }
    
    var headers: HeaderType {
        switch self {
        case .register(let header, _), .withdraw(let header):
            return header
        }
    }
    
    var parameterEncoding: any Alamofire.ParameterEncoding {
        switch self {
        case .register, .withdraw:
            return JSONEncoding.default
        }
    }
    
    var queryParameters: [String: String]? {
        nil
    }
    
    var bodyParameters: Alamofire.Parameters? {
        switch self {
        case .register(_, let dto):
            return dto.asParameters()
        case .withdraw:
            return nil
        }
    }
}
