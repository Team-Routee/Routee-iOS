//
//  ActivityRepository.swift
//  Routee-iOS
//
//  Created by 김세령 on 7/15/26.
//

import Foundation

protocol ActivityRepository {
    func getActivityRoute(activityId: Int64) async throws -> ActivityEditorModel
    func createActivity(activityType: String, startedAt: String) async throws -> WorkoutRecordStartModel
}

struct DefaultActivityRepository: ActivityRepository {

    private let service: NetworkService
    private let keychainService: KeychainService

    init(
        service: NetworkService = DefaultNetworkService(),
        keychainService: KeychainService = DefaultKeychainService()
    ) {
        self.service = service
        self.keychainService = keychainService
    }

    func getActivityRoute(activityId: Int64) async throws -> ActivityEditorModel {
        let accessToken = keychainService.read(.accessToken)

        guard !accessToken.isEmpty else {
            throw RouteeError.noData
        }

        let endPoint = ActivityAPI.activityRoute(
            header: .withAuth(accessToken: accessToken),
            activityId: activityId
        )

        let response = try await service.request(
            endPoint,
            decodingType: ActivityRouteResponseDTO.self
        )

        return response.toModel()
    }
    
    func createActivity(activityType: String, startedAt: String)
        async throws -> WorkoutRecordStartModel {
            let accessToken = keychainService.read(.accessToken)
            
            let dto = ActivityCreateRequestDTO(activityType: activityType, startedAt: startedAt)
            
            let endpoint = ActivityAPI.createActivity(
                header: .withAuthTimeZone(
                    accessToken: accessToken,
                    timeZone: TimeZone.current.identifier
                ),
                requestDTO: dto
            )
            
            let response = try await service.request(endpoint, decodingType: ActivityCreateResponseDTO.self)
            return response.toWorkoutRecordStartModel()
        }
}
