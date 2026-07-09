//
//  ReverseGeocodingRepository.swift
//  Routee-iOS
//
//  Created by LEESANGYUP on 7/8/26.
//

import Foundation

protocol ReverseGeocodingRepository {
    func roadAddress(latitude: Double, longitude: Double) async throws -> String
}

struct DefaultReverseGeocodingRepository: ReverseGeocodingRepository {
    private let service: NetworkService

    init(service: NetworkService = DefaultNetworkService()) {
        self.service = service
    }
    
    func roadAddress(latitude: Double, longitude: Double) async throws -> String {
        guard !ConfigManager.naverMapClientID.isEmpty,
              !ConfigManager.naverMapClientSecret.isEmpty
        else {
            throw RouteeError.configError
        }
        
        let decodedData = try await service.requestPlain(
            NaverMapsAPI.reverseGeocode(latitude: latitude, longitude: longitude),
            decodingType: NaverReverseGeocodeResponseDTO.self
        )
        
        let roadAddress = decodedData.results
            .first { $0.name == "roadaddr" }?
            .formattedAddress
        let fallbackAddress = decodedData.results.first?.formattedAddress
        
        guard let address = roadAddress ?? fallbackAddress,
              !address.isEmpty
        else {
            throw RouteeError.noData
        }
        
        return address
    }
}
