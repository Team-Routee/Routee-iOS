//
//  RouteeError.swift
//  Routee-iOS
//
//  Created by LEESANGYUP on 6/30/26.
//

import Foundation

enum RouteeError: LocalizedError, Equatable {
    case URLError
    case responseDecodingError
    case noData
    case unknownError
    case internalServerError(statusCode: Int)
    case clientError
    case codeError(String)
    case configError
    case forbidden
    case notFound
    case networkError(statusCode: Int, message: String)
    
    var errorDescription: String? {
        switch self {
        case .URLError:
            return "잘못된 URL"
        case .responseDecodingError:
            return "디코딩 에러"
        case .noData:
            return "데이터 없음"
        case .unknownError:
            return "알 수 없는 에러"
        case .internalServerError(let code):
            return "서버 에러 (Code: \(code))"
        case .clientError:
            return "클라이언트 요청 에러"
        case .codeError:
            return "코드 에러"
        case .configError:
            return "info에서 값을 찾을 수 없음"
        case .forbidden:
            return "접근 권한 없음"
        case .notFound:
            return "요청한 페이지를 찾을 수 없음"
        case .networkError(let code, let message):
            return "네트워크 연결을 확인하세요(Code: \(code), Message: \(message)"
        }
    }
}
