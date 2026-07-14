//
//  ArchiveRepository.swift
//  Routee-iOS
//
//  Created by 초긍정행운의포춘쿠키 on 7/13/26.
//

import Foundation

protocol ArchiveRepository {
    func activitySummary(year: Int, month: Int) async throws -> ActivitySummaryResponseDTO
}

struct DefaultArchiveRepository: ArchiveRepository {
    private let service: NetworkService
    
    init(service: NetworkService = DefaultNetworkService()) {
        self.service = service
    }
    
    func activitySummary(year: Int, month: Int) async throws -> ActivitySummaryResponseDTO {
        let requestDTO = ActivitySummaryRequestDTO(
            year: year,
            month: month
        )
        
        let endpoint = ArchiveAPI.activitySummary(
            header: .withAuth,
            requestDTO: requestDTO
        )
        
        return try await service.request(
            endpoint,
            decodingType: ActivitySummaryResponseDTO.self
        )
    }
}
