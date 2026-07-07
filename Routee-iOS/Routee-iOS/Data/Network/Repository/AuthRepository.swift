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
        
        let _: LoginResponseDTO = try await service.request(
            endpoint,
            decodingType: LoginResponseDTO.self
        )
    }
}
