//
//  AuthRepository.swift
//  Routee-iOS
//
//  Created by LEESANGYUP on 7/2/26.
//

import Foundation

protocol AuthRepository {
    func appleLogin(platform: LoginPlatform, identityToken: String, nickname: String) async throws
}

struct DefaultAuthRepository: AuthRepository {
    private let service: NetworkService
    private let keychainService = DefaultKeychainService()
    
    init(service: NetworkService = DefaultNetworkService()) {
        self.service = service
    }
    
    func appleLogin(platform: LoginPlatform, identityToken: String, nickname: String) async throws {
        let dto = LoginRequestDTO(
            provider: platform.mixpanelKey,
            idToken: identityToken,
            nickname: nickname
        )
        
        let endpoint = AuthAPI.login(
            header: .basic,
            requestDTO: dto
        )
        
        let response: LoginResponseDTO = try await service.request(
            endpoint,
            decodingType: LoginResponseDTO.self
        )
        
        keychainService.create(.accessToken, token: response.accessToken)
        keychainService.create(.refreshToken, token: response.refreshToken)
    }
}
