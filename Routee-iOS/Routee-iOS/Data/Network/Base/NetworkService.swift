//
//  NetworkService.swift
//  Routee-iOS
//
//  Created by LEESANGYUP on 6/30/26.
//

import AuthenticationServices
import Foundation

import Alamofire

protocol NetworkService {
    func request<T: Decodable & Sendable>(
        _ endPoint: EndPoint,
        decodingType: T.Type
    ) async throws -> T
}

final class DefaultNetworkService: NetworkService {
    func request<T: Decodable & Sendable>(
        _ endPoint: EndPoint,
        decodingType: T.Type
    ) async throws -> T {
        Self.requestLogger(endPoint)
        return try await withCheckedThrowingContinuation { continuation in
            AF.request(
                endPoint.requestURL,
                method: endPoint.method,
                parameters: endPoint.bodyParameters,
                encoding: endPoint.parameterEncoding,
                headers: endPoint.headers.value
            )
            .validate()
            .responseDecodable(of: BaseResponse<T>.self) { response in
                Self.responseLogger(response)
                
                switch response.result {
                case .success(let data):
                    guard let data = data.data else {
                        RouteeLogger.error(RouteeError.noData)
                        continuation.resume(throwing: RouteeError.noData)
                        return
                    }
                    RouteeLogger.data("Decoded Data: \(data)")
                    continuation.resume(returning: data)
                case .failure:
                    if let data = response.data,
                       let statusCode = response.response?.statusCode,
                       let errorResponse = try? JSONDecoder().decode(
                        BaseResponse<T>.self, from: data
                       ) {
                        let error = Self.handleError(statusCode, errorResponse.message)
                        RouteeLogger.error(error)
                        continuation.resume(throwing: error)
                    } else {
                        RouteeLogger.error(RouteeError.responseDecodingError)
                        continuation.resume(throwing: RouteeError.responseDecodingError)
                    }
                }
            }
        }
    }
    
    private static func requestLogger(_ endPoint: EndPoint) {
        RouteeLogger.network("[Reqeust Start]")
        RouteeLogger.network("URL: \(endPoint.requestURL)")
        RouteeLogger.network("Method: \(endPoint.method.rawValue)")
        RouteeLogger.network("Headers: \(endPoint.headers.value)")
        RouteeLogger.network("Parameters: \(String(describing: endPoint.bodyParameters))")
    }
    
    private static func responseLogger<T>(_ response: DataResponse<T, AFError>) {
        RouteeLogger.network("[Response Start]")
        RouteeLogger.network("StatusCode: \(response.response?.statusCode ?? 0)")
        RouteeLogger.network("Header: \(response.response?.headers ?? HTTPHeaders())")
        RouteeLogger.network("Description: \(response.response?.description ?? "nil")")
    }
    
    private static func handleError(_ statusCode: Int, _ errorResponse: String) -> RouteeError {
        let error: RouteeError
        
        if statusCode == 404 {
            error = RouteeError.notFound
        } else if statusCode == 403 {
            error = RouteeError.forbidden
        } else if statusCode == 400 {
            error = RouteeError.clientError
        } else if statusCode == 408 || (500...599) ~= statusCode {
            error = RouteeError.internalServerError(statusCode: statusCode)
        } else {
            error = RouteeError.networkError(
                statusCode: statusCode,
                message: errorResponse
            )
        }
        
        return error
    }
}
