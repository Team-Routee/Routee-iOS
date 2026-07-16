//
//  ActivityRepository.swift
//  Routee-iOS
//
//  Created by 김세령 on 7/15/26.
//

import Foundation

protocol ActivityRepository {
    func getActivityRoute(activityId: Int64) async throws -> ActivityEditorModel
    func getActivityStatistics(activityId: Int64) async throws -> TimeLineMetricModel
    func getActivityTimelineList(activityId: Int64) async throws -> TimeLineData
    func getActivityCourseList(activityId: Int64) async throws -> CourseData
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

    func getActivityStatistics(activityId: Int64) async throws -> TimeLineMetricModel {
        let accessToken = keychainService.read(.accessToken)

        guard !accessToken.isEmpty else {
            throw RouteeError.noData
        }

        let endPoint = ActivityAPI.activityStatistics(
            header: .withAuthTimeZone(
                accessToken: accessToken,
                timeZone: TimeZone.current.identifier
            ),
            activityId: activityId
        )

        let response = try await service.request(
            endPoint,
            decodingType: ActivityStatisticsResponseDTO.self
        )

        return response.toModel()
    }

    func getActivityTimelineList(activityId: Int64) async throws -> TimeLineData {
        let accessToken = keychainService.read(.accessToken)

        guard !accessToken.isEmpty else {
            throw RouteeError.noData
        }

        let endPoint = ActivityAPI.activityTimelineList(
            header: .withAuth(accessToken: accessToken),
            activityId: activityId
        )

        let response = try await service.request(
            endPoint,
            decodingType: ActivityTimelineListResponseDTO.self
        )

        return response.toModel()
    }

    func getActivityCourseList(activityId: Int64) async throws -> CourseData {
        let accessToken = keychainService.read(.accessToken)

        guard !accessToken.isEmpty else {
            throw RouteeError.noData
        }

        let endPoint = ActivityAPI.activityCourseList(
            header: .withAuth(accessToken: accessToken),
            activityId: activityId
        )

        let response = try await service.request(
            endPoint,
            decodingType: ActivityCourseListResponseDTO.self
        )

        return response.toModel()
    }
}
