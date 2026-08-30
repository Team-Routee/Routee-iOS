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
    func getActivityStatistics(activityId: Int64) async throws -> TimeLineMetricModel
    func getActivityTimelineList(activityId: Int64) async throws -> TimeLineData
    func getActivityCourseList(activityId: Int64) async throws -> CourseData
    func createActivity(activityType: String, startedAt: String) async throws -> WorkoutRecordStartModel
    func timeLinePresignedURL(activityId: Int64, fileName: String) async throws -> ImagePresignedURLModel
    func uploadTimeLineImage(presignedURL: String, imageData: Data) async throws
    func createTimeLine(activityId: Int64, requestDTO: CreateTimeLineRequestDTO) async throws -> Int64
    func backgroundMapPresignedURL(activityId: Int64, requestDTO: BackgroundMapPresignedURLRequestDTO) async throws -> ImagePresignedURLModel
    func finishActivity(activityId: Int64, requestModel: WorkoutRecordFinishModel) async throws
    func changeActivityStatus(activityId: Int64, requestDTO: ChangeActivityStatusRequestDTO) async throws -> ChangeActivityStatusResponseDTO
    func updateArchiveActivityTitle(activityId: Int64, requestDTO: UpdateArchiveActivityTitleRequestDTO) async throws -> UpdateArchiveActivityTitleResponseDTO
    func createCourseList(activityId: Int64, requestDTO: CreateCourseListRequestDTO) async throws -> CourseListModel
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
    
    func createTimeLine(activityId: Int64, requestDTO: CreateTimeLineRequestDTO) async throws -> Int64 {
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
        
        let response = try await service.request(
            endpoint,
            decodingType: CreateTimeLineResponseDTO.self
        )
        return response.timelineId
    }
    
    func backgroundMapPresignedURL(activityId: Int64, requestDTO: BackgroundMapPresignedURLRequestDTO) async throws -> ImagePresignedURLModel{
        let accessToken = keychainService.read(.accessToken)
        
        guard !accessToken.isEmpty else {
            throw RouteeError.forbidden
        }
                
        let endpoint = ActivityAPI.backgroundMapPresignedURL(
            header: .withAuth(accessToken: accessToken),
            activityId: activityId,
            requestDTO: requestDTO
        )
        
        let response = try await service.request(endpoint, decodingType: BackgroundMapPresignedURLResponseDTO.self)
        return response.toImagePresignedURLModel()
    }
    
    func finishActivity(activityId: Int64, requestModel: WorkoutRecordFinishModel) async throws {
        let accessToken = keychainService.read(.accessToken)
        
        guard !accessToken.isEmpty else {
            throw RouteeError.forbidden
        }
        
        let endpoint = ActivityAPI.finishActivity(
            header: .withAuthTimeZone(accessToken: accessToken, timeZone: TimeZone.current.identifier),
            activityId: activityId,
            requestDTO: requestModel.toDTO()
        )
        
        return try await service.requestEmpty(endpoint)
    }
    
    func changeActivityStatus(activityId: Int64, requestDTO: ChangeActivityStatusRequestDTO) async throws -> ChangeActivityStatusResponseDTO {
        let accessToken = keychainService.read(.accessToken)
        
        guard !accessToken.isEmpty else {
            throw RouteeError.forbidden
        }
                
        let endpoint = ActivityAPI.changeActivityStatus(
            header: .withAuth(accessToken: accessToken),
            activityId: activityId,
            requestDTO: requestDTO
        )
        
        let response = try await service.request(endpoint, decodingType: ChangeActivityStatusResponseDTO.self)
        return response
    }

    func updateArchiveActivityTitle(activityId: Int64, requestDTO: UpdateArchiveActivityTitleRequestDTO) async throws -> UpdateArchiveActivityTitleResponseDTO {
        let accessToken = keychainService.read(.accessToken)

        guard !accessToken.isEmpty else {
            throw RouteeError.forbidden
        }

        let endpoint = ActivityAPI.updateArchiveActivityTitle(
            header: .withAuth(accessToken: accessToken),
            activityId: activityId,
            requestDTO: requestDTO
        )

        return try await service.request(
            endpoint,
            decodingType: UpdateArchiveActivityTitleResponseDTO.self
        )
    }
    
    func createCourseList(activityId: Int64, requestDTO: CreateCourseListRequestDTO) async throws -> CourseListModel {
        let accessToken = keychainService.read(.accessToken)

        guard !accessToken.isEmpty else {
            throw RouteeError.forbidden
        }

        let endpoint = ActivityAPI.createCourseList(
            header: .withAuth(accessToken: accessToken),
            activityId: activityId,
            requestDTO: requestDTO
        )

        let response = try await service.request(endpoint, decodingType: CreateCourseListResponseDTO.self)
        return response.toModel()
    }
}
