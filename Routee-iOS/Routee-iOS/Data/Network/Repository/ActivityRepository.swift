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
    func timeLinePresignedURL(activityId: Int64, fileName: String) async throws -> ImagePresignedURLModel
    func uploadTimeLineImage(presignedURL: String, imageData: Data) async throws
    func createTimeLine(activityId: Int64, requestDTO: CreateTimeLineRequestDTO) async throws
    func backgroundMapPresignedURL(activityId: Int64, requestDTO: BackgroundMapPresignedURLRequestDTO) async throws -> ImagePresignedURLModel
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
        
        guard !accessToken.isEmpty else {
            throw RouteeError.forbidden
        }
        
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
    
    func timeLinePresignedURL(activityId: Int64, fileName: String) async throws -> ImagePresignedURLModel {
        let accessToken = keychainService.read(.accessToken)
        
        guard !accessToken.isEmpty else {
            throw RouteeError.forbidden
        }
        
        let dto = TimeLinePresignedURLRequestDTO(fileName: fileName)
        
        let endpoint = ActivityAPI.timeLinePresignedURL(
            header: .withAuth(accessToken: accessToken),
            activityId: activityId,
            requestDTO: dto
        )
        
        let response = try await service.request(endpoint, decodingType: TimeLinePresignedURLResponseDTO.self)
        return response.toImagePresignedURLModel()
    }
    
    func uploadTimeLineImage(presignedURL: String, imageData: Data) async throws {
        try await service.presignedURLUploadData(imageData, to: presignedURL, contentType: "image/jpeg")
    }
    
    func createTimeLine(activityId: Int64, requestDTO: CreateTimeLineRequestDTO) async throws {
        let accessToken = keychainService.read(.accessToken)
        
        guard !accessToken.isEmpty else {
            throw RouteeError.forbidden
        }
        
        let dto = requestDTO
        
        let endpoint = ActivityAPI.createTimeLine(
            header: .withAuthTimeZone(accessToken: accessToken, timeZone: TimeZone.current.identifier),
            activityId: activityId,
            requestDTO: dto
        )
        
        try await service.requestEmpty(endpoint)
    }
    
    func backgroundMapPresignedURL(activityId: Int64, requestDTO: BackgroundMapPresignedURLRequestDTO) async throws -> ImagePresignedURLModel{
        let accessToken = keychainService.read(.accessToken)
        
        guard !accessToken.isEmpty else {
            throw RouteeError.forbidden
        }
        
        let dto = requestDTO
        
        let endpoint = ActivityAPI.backgroundMapPresignedURL(
            header: .withAuth(accessToken: accessToken),
            activityId: activityId,
            requestDTO: requestDTO
        )
        
        let response = try await service.request(endpoint, decodingType: BackgroundMapPresignedURLResponseDTO.self)
        return response.toImagePresignedURLModel()
    }
}
