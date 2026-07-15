//
//  ActivityRepository.swift
//  Routee-iOS
//
//  Created by 김세령 on 7/15/26.
//

protocol ActivityRepository {
    func getActivityRoute(activityId: Int64) async throws -> ActivityEditorModel
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
}
