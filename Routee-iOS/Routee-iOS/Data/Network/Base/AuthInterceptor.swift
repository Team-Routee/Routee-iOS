//
//  AuthInterceptor.swift
//  Routee-iOS
//
//  Created by LEESANGYUP on 7/14/26.
//

import Foundation

import Alamofire

final class AuthInterceptor: RequestInterceptor {
    private let tokenService: TokenService
    private let keychainService: KeychainService
    private let retryLimit = 1

    init(tokenService: TokenService, keychainService: KeychainService) {
        self.tokenService = tokenService
        self.keychainService = keychainService
    }

    func adapt(
        _ urlRequest: URLRequest,
        for session: Session,
        completion: @escaping (Result<URLRequest, any Error>) -> Void
    ) {
        let accessToken = keychainService.read(.accessToken)

        guard !accessToken.isEmpty else {
            completion(.failure(RouteeError.unauthorized))
            return
        }

        var urlRequest = urlRequest
        urlRequest.setValue("Bearer \(accessToken)", forHTTPHeaderField: "Authorization")
        completion(.success(urlRequest))
    }

    func retry(
        _ request: Request,
        for session: Session,
        dueTo error: any Error,
        completion: @escaping @Sendable (RetryResult) -> Void
    ) {
        guard
            request.response?.statusCode == 401,
            request.retryCount < retryLimit
        else {
            completion(.doNotRetryWithError(error))
            return
        }

        Task {
            do {
                try await tokenService.reissue()
                completion(.retry)
            } catch {
                completion(.doNotRetryWithError(RouteeError.unauthorized))
            }
        }
    }
}
