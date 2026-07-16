//
//  AuthAPI.swift
//  Routee-iOS
//
//  Created by LEESANGYUP on 7/6/26.
//

import Foundation

import Alamofire

enum AuthAPI {
    case login(header: HeaderType, requestDTO: LoginRequestDTO)
    case reissue(header: HeaderType, requestDTO: TokenReissueRequestDTO)
    case logout(header: HeaderType, requestDTO: LogoutRequestDTO)
}

extension AuthAPI: RouteeEndPoint {
    var basePath: String {
        switch self {
        case .login, .reissue, .logout:
            "/api/v1/auth"
        }
    }
    
    var path: String {
        switch self {
        case .login:
            return "/login"
        case .reissue:
            return "/reissue"
        case .logout:
            return "/logout"
        }
    }
    
    var method: Alamofire.HTTPMethod {
        switch self {
        case .login, .reissue, .logout:
            return .post
        }
    }
    
    var headers: HeaderType {
        switch self {
        case .login(let header, _), .reissue(let header, _), .logout(let header, _):
            return header
        }
    }
    
    var parameterEncoding: any Alamofire.ParameterEncoding {
        switch self {
        case .login, .reissue, .logout:
            return JSONEncoding.default
        }
    }
    
    var queryParameters: [String: String]? {
        nil
    }
    
    var bodyParameters: Alamofire.Parameters? {
        switch self {
        case .login(_, let dto):
            return dto.asParameters()
        case .reissue(_, let dto):
            return dto.asParameters()
        case .logout(_, let dto):
            return dto.asParameters()
        }
    }
}
