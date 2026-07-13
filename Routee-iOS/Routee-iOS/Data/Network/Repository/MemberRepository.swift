//
//  MemberRepository.swift
//  Routee-iOS
//
//  Created by LEESANGYUP on 7/13/26.
//

import Foundation

protocol MemberRepository {
    func register(nickname: String, identityToken: String, provider: LoginPlatform) async throws
    func withdraw(refreshToken: String) async throws
}

struct DefaultMemberRepository: MemberRepository {
    private let service: NetworkService
    private let keychainService = DefaultKeychainService()

    init(service: NetworkService = DefaultNetworkService()) {
        self.service = service
    }
    
    func register(nickname: String, identityToken: String, provider: LoginPlatform) async throws {
        let dto = RegisterRequestDTO(
            nickname: nickname,
            idToken: identityToken,
            provider: provider.mixpanelKey
        )
        
        let endPoint = MemberAPI.register(
            header: .basic,
            requestDTO: dto
        )
        
        let response: EmptyResponse = try await service.request(endPoint, decodingType: EmptyResponse.self)
    }
    
    func withdraw(refreshToken: String) async throws {
        let refreshToken = keychainService.read(.refreshToken)
        let endPoint = MemberAPI.withdraw(header: .basic)
        let response: EmptyResponse = try await service.request(endPoint, decodingType: EmptyResponse.self)
    }
}
