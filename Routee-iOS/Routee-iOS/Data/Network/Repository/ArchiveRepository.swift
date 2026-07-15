//
//  ArchiveRepository.swift
//  Routee-iOS
//
//  Created by 초긍정행운의포춘쿠키 on 7/13/26.
//

import Foundation

protocol ArchiveRepository {
    func getArchive(year: Int, month: Int) async throws -> [ArchiveModel]
    func getActivityList(date: String) async throws -> ActivityListDateModel
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
    
    func getArchive(year: Int, month: Int) async throws -> [ArchiveModel] {
        let accessToken = keychainService.read(.accessToken)

        guard !accessToken.isEmpty else {
            throw RouteeError.noData
        }

        let requestDTO = ActivitySummaryRequestDTO(
            year: year,
            month: month
        )
        
        let endpoint = ArchiveAPI.getArchive(
            header: .withAuth(accessToken: accessToken),
            requestDTO: requestDTO
        )
        
        let response = try await service.request(
            endpoint,
            decodingType: ActivitySummaryResponseDTO.self
        )

        return response.toModel()
    }

    func getActivityList(date: String) async throws -> ActivityListDateModel {
        let accessToken = keychainService.read(.accessToken)

        guard !accessToken.isEmpty else {
            throw RouteeError.noData
        }

        let requestDTO = ActivityListRequestDTO(date: date)
        let endpoint = ArchiveAPI.getActivityList(
            header: .withAuthTimeZone(
                accessToken: accessToken,
                timeZone: TimeZone.current.identifier
            ),
            requestDTO: requestDTO
        )

        let response = try await service.request(
            endpoint,
            decodingType: ActivityListResponseDTO.self
        )

        return response.toModel()
    }
}
