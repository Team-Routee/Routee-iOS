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
    case withdraw(header: HeaderType, requestDTO: WithdrawRequestDTO)
    case getProfile(header: HeaderType)
    case getMemberProfile(header: HeaderType)
    case updateNickname(header: HeaderType, requestDTO: UpdateNicknameRequestDTO)
    case profileImagePresignedURL(header: HeaderType, requestDTO: ProfileImagePresignedURLRequestDTO)
    case updateProfileImage(header: HeaderType, requestDTO: UpdateProfileImageRequestDTO)
    case updateDefaultProfileImage(header: HeaderType)
}

extension MemberAPI: RouteeEndPoint {
    var basePath: String {
        switch self {
        case .register,
             .withdraw,
             .getProfile,
             .getMemberProfile,
             .updateNickname,
             .profileImagePresignedURL,
             .updateProfileImage,
             .updateDefaultProfileImage:
            return "/api/v1/member"
        }
    }
    
    var path: String {
        switch self {
        case .register:
            return "/register"
        case .withdraw:
            return "/withdraw"
        case .getProfile:
            return "/summary"
        case .getMemberProfile:
            return "/profile"
        case .updateNickname:
            return "/nickname"
        case .profileImagePresignedURL:
            return "/profile-image/upload-url"
        case .updateProfileImage:
            return "/profile-image"
        case .updateDefaultProfileImage:
            return "/profile-image/default"
        }
    }
    
    var method: Alamofire.HTTPMethod {
        switch self {
        case .register:
            return  .post
        case .withdraw:
            return .delete
        case .getProfile:
            return .get
        case .getMemberProfile:
            return .get
        case .updateNickname, .updateProfileImage, .updateDefaultProfileImage:
            return .patch
        case .profileImagePresignedURL:
            return .post
        }
    }
    
    var headers: HeaderType {
        switch self {
        case .register(let header, _),
             .withdraw(let header, _),
             .updateNickname(let header, _),
             .profileImagePresignedURL(let header, _),
             .updateProfileImage(let header, _):
            return header
        case .getProfile(let header),
             .getMemberProfile(let header),
             .updateDefaultProfileImage(let header):
            return header
        }
    }
    
    var parameterEncoding: any Alamofire.ParameterEncoding {
        switch self {
        case .register,
             .withdraw,
             .updateNickname,
             .profileImagePresignedURL,
             .updateProfileImage:
            return JSONEncoding.default
        case .getProfile, .getMemberProfile, .updateDefaultProfileImage:
            return URLEncoding.default
        }
    }
    
    var queryParameters: [String: String]? {
        nil
    }
    
    var bodyParameters: Alamofire.Parameters? {
        switch self {
        case .register(_, let dto):
            return dto.asParameters()
        case .withdraw(_, let dto):
            return dto.asParameters()
        case .getProfile, .getMemberProfile:
            return nil
        case .updateNickname(_, let dto):
            return dto.asParameters()
        case .profileImagePresignedURL(_, let dto):
            return dto.asParameters()
        case .updateProfileImage(_, let dto):
            return dto.asParameters()
        case .updateDefaultProfileImage:
            return nil
        }
    }
}
