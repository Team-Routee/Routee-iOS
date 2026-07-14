//
//  ArchiveRepository.swift
//  Routee-iOS
//
//  Created by 초긍정행운의포춘쿠키 on 7/13/26.
//

import Foundation

protocol ArchiveRepository {
    func archive(year: Int, month: Int) async throws -> ArchiveResponseDTO
}

struct DefaultArchiveRepository: ArchiveRepository {
    private let service: NetworkService
    private let keychainService: KeychainService

    init(
        service: NetworkService = DefaultNetworkService(),
        keychainService: KeychainService = DefaultKeychainService()
    ) {
        self.service = service
        self.keychainService = keychainService
    }
    
    func archive(year: Int, month: Int) async throws -> ArchiveResponseDTO {
        let accessToken = keychainService.read(.accessToken)

        guard !accessToken.isEmpty else {
            throw RouteeError.noData
        }

        let requestDTO = ArchiveRequestDTO(
            year: year,
            month: month
        )
        
        let endpoint = ArchiveAPI.archive(
            header: .withAuth(accessToken: accessToken),
            requestDTO: requestDTO
        )
        
        return try await service.request(
            endpoint,
            decodingType: ArchiveResponseDTO.self
        )
    }
}
