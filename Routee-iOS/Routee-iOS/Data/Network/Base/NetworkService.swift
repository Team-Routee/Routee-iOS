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
    func request<T: Decodable & Sendable>(_ endPoint: EndPoint, decodingType: T.Type) async throws -> T
    
    func requestEmpty(_ endPoint: EndPoint) async throws
    
    func requestPlain<T: Decodable & Sendable>(_ endPoint: EndPoint, decodingType: T.Type) async throws -> T
    
    func presignedURLUploadData(_ data: Data, to urlString: String, contentType: String) async throws
}

final class DefaultNetworkService: NetworkService {
    private static let authorizedSession: Session = {
        let keychainService = DefaultKeychainService()
        let interceptor = AuthInterceptor(
            tokenService: DefaultTokenService(keychainService: keychainService),
            keychainService: keychainService
        )
        return Session(interceptor: interceptor)
    }()
    
    private static func session(for endPoint: EndPoint) -> Session {
        switch endPoint.headers {
        case .withAuth, .withAuthTimeZone:
            return authorizedSession
        default:
            return AF
        }
    }
    
    func request<T: Decodable & Sendable>(_ endPoint: EndPoint, decodingType: T.Type) async throws -> T {
        Self.requestLogger(endPoint)
        return try await withCheckedThrowingContinuation { continuation in
            Self.session(for: endPoint).request(
                endPoint.requestURL,
                method: endPoint.method,
                parameters: endPoint.bodyParameters,
                encoding: endPoint.parameterEncoding,
                headers: endPoint.headers.value
            )
            .validate()
            .responseDecodable(of: BaseResponse<T>.self) { response in
                Self.responseLogger(response)
                Self.rawResponseLogger(response.data)
                
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
    
    func requestEmpty(_ endPoint: EndPoint) async throws {
        Self.requestLogger(endPoint)
        return try await withCheckedThrowingContinuation { continuation in
            Self.session(for: endPoint).request(
                endPoint.requestURL,
                method: endPoint.method,
                parameters: endPoint.bodyParameters,
                encoding: endPoint.parameterEncoding,
                headers: endPoint.headers.value
            )
            .validate()
            .responseDecodable(of: EmptyResponse.self) { response in
                Self.responseLogger(response)
                Self.rawResponseLogger(response.data)
                
                switch response.result {
                case .success(let response):
                    RouteeLogger.data("Response Code: \(response.code)")
                    continuation.resume(returning: ())
                case .failure(let error):
                    if let data = response.data,
                       let statusCode = response.response?.statusCode,
                       let errorResponse = try? JSONDecoder().decode(
                        EmptyResponse.self,
                        from: data
                       ) {
                        let error = Self.handleError(statusCode, errorResponse.message)
                        RouteeLogger.error(error)
                        continuation.resume(throwing: error)
                    } else {
                        RouteeLogger.error(error)
                        continuation.resume(throwing: error)
                    }
                }
            }
        }
    }
    
    func requestPlain<T: Decodable & Sendable>(_ endPoint: EndPoint, decodingType: T.Type) async throws -> T {
        Self.requestLogger(endPoint)
        return try await withCheckedThrowingContinuation { continuation in
            Self.session(for: endPoint).request(
                endPoint.requestURL,
                method: endPoint.method,
                parameters: endPoint.bodyParameters,
                encoding: endPoint.parameterEncoding,
                headers: endPoint.headers.value
            )
            .validate()
            .responseDecodable(of: T.self) { response in
                Self.responseLogger(response)
                Self.rawResponseLogger(response.data)
                
                switch response.result {
                case .success(let data):
                    RouteeLogger.data("Decoded Data: \(data)")
                    continuation.resume(returning: data)
                case .failure(let error):
                    if let statusCode = response.response?.statusCode {
                        let error = Self.handleError(statusCode, error.localizedDescription)
                        RouteeLogger.error(error)
                        
                        continuation.resume(throwing: error)
                    } else {
                        RouteeLogger.error(error)
                        continuation.resume(throwing: error)
                    }
                }
            }
        }
    }
    
    func presignedURLUploadData(_ data: Data, to urlString: String, contentType: String) async throws {
        guard let url = URL(string: urlString) else {
            throw RouteeError.URLError
        }
        
        RouteeLogger.network("[Upload Start]")
        RouteeLogger.network("Host: \(url.host() ?? "nil"), Size: \(data.count) bytes")
        
        return try await withCheckedThrowingContinuation { continuation in
            AF.upload(
                data,
                to: url,
                method: .put,
                headers: ["Content-Type": contentType]
            )
            .validate()
            .response { response in
                RouteeLogger.network("Upload StatusCode: \(response.response?.statusCode ?? 0)")
                
                switch response.result {
                case .success:
                    continuation.resume(returning: ())
                case .failure(let error):
                    if let statusCode = response.response?.statusCode {
                        let error = Self.handleError(statusCode, error.localizedDescription)
                        RouteeLogger.error(error)
                        continuation.resume(throwing: error)
                    } else {
                        RouteeLogger.error(error)
                        continuation.resume(throwing: error)
                    }
                }
            }
        }
    }
    
    private static func requestLogger(_ endPoint: EndPoint) {
        RouteeLogger.network("[Reqeust Start]")
        RouteeLogger.network("URL: \(endPoint.requestURL)")
        RouteeLogger.network("Method: \(endPoint.method.rawValue)")
        RouteeLogger.network("Headers: \(maskedHeaders(endPoint.headers.value))")
        RouteeLogger.network("Parameters: \(String(describing: maskedParameters(endPoint.bodyParameters)))")
    }
    
    private static func maskedHeaders(_ headers: HTTPHeaders) -> [String: String] {
        Dictionary(uniqueKeysWithValues: headers.map { header in
            let shouldMask = [
                "Authorization",
                "X-Apple-Code",
                "X-NCP-APIGW-API-KEY"
            ].contains(header.name)
            
            return (header.name, shouldMask ? "********" : header.value)
        })
    }
    
    private static func maskedParameters(_ parameters: Parameters?) -> Parameters? {
        guard let parameters else { return nil }
        
        return parameters.reduce(into: Parameters()) { result, item in
            let key = item.key.lowercased()
            let shouldMask = key.contains("token") || key.contains("code")
            result[item.key] = shouldMask ? "********" : item.value
        }
    }
    
    private static func responseLogger<T>(_ response: DataResponse<T, AFError>) {
        RouteeLogger.network("[Response Start]")
        RouteeLogger.network("StatusCode: \(response.response?.statusCode ?? 0)")
        RouteeLogger.network("Header: \(response.response?.headers ?? HTTPHeaders())")
        RouteeLogger.network("Description: \(response.response?.description ?? "nil")")
    }
    
    private static func rawResponseLogger(_ data: Data?) {
        guard
            let data,
            let rawBody = String(data: data, encoding: .utf8)
        else {
            RouteeLogger.network("Raw response: nil")
            print("Raw response: nil")
            return
        }
        
        RouteeLogger.network("Raw response: \(rawBody)")
        print("Raw response:", rawBody)
    }
    
    private static func handleError(_ statusCode: Int, _ errorResponse: String) -> RouteeError {
        let error: RouteeError
        
        if statusCode == 404 {
            error = RouteeError.notFound
        } else if statusCode == 401 {
            error = RouteeError.unauthorized
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
