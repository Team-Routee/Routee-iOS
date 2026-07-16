//
//  AuthRepository.swift
//  Routee-iOS
//
//  Created by LEESANGYUP on 7/2/26.
//

import Foundation

protocol AuthRepository {
    func login(platform: LoginPlatform, identityToken: String, appleUserID: String) async throws
    func logout(requestDTO: LogoutRequestDTO) async throws
}

struct DefaultAuthRepository: AuthRepository {
    private let service: NetworkService
    private let keychainService = DefaultKeychainService()
    
    init(service: NetworkService = DefaultNetworkService()) {
        self.service = service
    }
    
    func login(platform: LoginPlatform, identityToken: String, appleUserID: String) async throws {
        let dto = LoginRequestDTO(
            provider: platform.mixpanelKey,
            idToken: identityToken
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
        keychainService.create(.appleUserID, token: appleUserID)
    }
    
    func logout(requestDTO: LogoutRequestDTO) async throws {
        let accessToken = keychainService.read(.accessToken)

        guard !accessToken.isEmpty else {
            throw RouteeError.forbidden
        }
        
        let endpoint = AuthAPI.logout(
            header: .withAuth(accessToken: accessToken),
            requestDTO: requestDTO
        )
        
        return try await service.requestEmpty(endpoint)
    }
}
