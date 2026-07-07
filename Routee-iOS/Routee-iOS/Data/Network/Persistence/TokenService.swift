//
//  TokenService.swift
//  Routee-iOS
//
//  Created by LEESANGYUP on 7/7/26.
//

import Foundation

import Alamofire

protocol TokenService: Sendable {
    func reissue() async throws
}

actor DefaultTokenService: TokenService {
    private var tokenTask: Task<Void, Error>?
    private let keychainService: KeychainService
    
    init(keychainService: KeychainService) {
        self.keychainService = keychainService
    }
    
    func reissue() async throws {
        if let task = tokenTask {
            return try await task.value
        }
        let refreshToken = keychainService.read(.refreshToken)

        guard !refreshToken.isEmpty else {
            throw RouteeError.noData
        }

        let requestDTO = TokenReissueRequestDTO(refreshToken: refreshToken)
        
        let task = Task {
            try await fetchAuthReissue(refreshToken: requestDTO)
        }
        
        tokenTask = task
        defer { tokenTask = nil }
        
        return try await task.value
    }
    
    private func fetchAuthReissue(refreshToken: TokenReissueRequestDTO) async throws {
        let header: HeaderType = .refresh(accessToken: keychainService.read(.accessToken))
        let endPoint: EndPoint = AuthAPI.reissue(header: header, requestDTO: refreshToken)
        RouteeLogger.debug("토큰 재발급 시작")
        
        return try await withCheckedThrowingContinuation { [weak self] continuation in
            guard let self else {
                continuation.resume(throwing: RouteeError.unknownError)
                return
            }
            
            AF.request(
                endPoint.requestURL,
                method: endPoint.method,
                parameters: endPoint.bodyParameters,
                encoding: endPoint.parameterEncoding,
                headers: endPoint.headers.value
            )
            .validate()
            .responseDecodable(
                of: BaseResponse<TokenReissueResponseDTO>.self,
                queue: DispatchQueue.global()
            ) { [weak self] response in
                guard let self else {
                    continuation.resume(throwing: RouteeError.unknownError)
                    return
                }
                RouteeLogger.debug("💡Reissue \(response)")
                
                switch response.result {
                case .success(let response):
                    guard let response = response.data else {
                        RouteeLogger.error(RouteeError.noData)
                        continuation.resume(throwing: RouteeError.noData)
                        return
                    }
                    
                    Task {
                        await self.tokenReissueSuccess(response)
                        continuation.resume(returning: ())
                    }
                case .failure(let error):
                    Task {
                        await self.tokenReissueFail()
                        continuation.resume(throwing: error)
                    }
                }
            }
        }
    }
    
    private func tokenReissueSuccess(_ data: TokenReissueResponseDTO) {
        RouteeLogger.debug("토큰 재발급 완료")
        self.keychainService.create(.accessToken, token: data.accessToken)
        self.keychainService.create(.refreshToken, token: data.refreshToken)
    }
    
    private func tokenReissueFail() {
        RouteeLogger.debug("토큰 재발급 실패, 키체인 삭제 후 로그인으로 이동")
        clearKeychain()
        Task { @MainActor in
            NotificationCenter.default.post(name: .navigateLoginViewController, object: nil)
        }
    }
    
    private func clearKeychain() {
        for key in KeyType.allCases {
            let token = keychainService.read(key)
            keychainService.delete(key)
            RouteeLogger.debug("\(key) 삭제")
        }
    }
}
