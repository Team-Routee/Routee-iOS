//
//  ActivityRepository.swift
//  Routee-iOS
//
//  Created by 김세령 on 7/15/26.
//

import Foundation

protocol ActivityRepository {
    func getActivityRoute(activityId: Int64) async throws -> ActivityEditorModel
    func getRecordEditResource(activityId: Int64) async throws -> RecordEditResourceModel
    func getWorkoutList(year: Int, month: Int) async throws -> [WorkoutListModel]
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

    func getRecordEditResource(activityId: Int64) async throws -> RecordEditResourceModel {
        let accessToken = keychainService.read(.accessToken)

        guard !accessToken.isEmpty else {
            throw RouteeError.noData
        }

        let endPoint = ActivityAPI.recordEditResource(
            header: .withAuth(accessToken: accessToken),
            activityId: activityId
        )

        let response = try await service.request(
            endPoint,
            decodingType: RecordEditResourceResponseDTO.self
        )

        return response.toModel()
    }

    func getWorkoutList(year: Int, month: Int) async throws -> [WorkoutListModel] {
        let accessToken = keychainService.read(.accessToken)

        guard !accessToken.isEmpty else {
            throw RouteeError.noData
        }

        let requestDTO = WorkoutListRequestDTO(
            year: year,
            month: month
        )

        let endPoint = ActivityAPI.workoutList(
            header: .withAuthTimeZone(
                accessToken: accessToken,
                timeZone: TimeZone.current.identifier
            ),
            requestDTO: requestDTO
        )

        let response = try await service.request(
            endPoint,
            decodingType: WorkoutListResponseDTO.self
        )

        return response.toModel()
    }
}
