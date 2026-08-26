//
//  RecordEditActivityRepository.swift
//  Routee-iOS
//
//  Created by 김세령 on 8/19/26.
//

import Foundation

enum RecordEditActivityRepository {

    private static let mockArgument = "-recordEditMockRepository"

    static var isMockEnabled: Bool {
        ProcessInfo.processInfo.arguments.contains(mockArgument)
    }

    static func make() -> ActivityRepository {
        if isMockEnabled {
            return MockActivityRepository()
        }

        return DefaultActivityRepository()
    }
}

struct MockActivityRepository: ActivityRepository {

    func getActivityRoute(activityId: Int64) async throws -> ActivityEditorModel {
        ActivityEditorModel(
            activityId: activityId,
            trackPoints: TrackPoint.dummyTrackPoints(),
            timelineMarkers: [
                TimelineMarkerModel(
                    timelineId: 1,
                    thumbnailUrl: "",
                    latitude: 37.5680,
                    longitude: 126.9790,
                    pointIndex: 2
                ),
                TimelineMarkerModel(
                    timelineId: 2,
                    thumbnailUrl: "",
                    latitude: 37.5710,
                    longitude: 126.9830,
                    pointIndex: 6
                ),
                TimelineMarkerModel(
                    timelineId: 3,
                    thumbnailUrl: "",
                    latitude: 37.5755,
                    longitude: 126.9805,
                    pointIndex: 12
                )
            ]
        )
    }

    func getRecordEditResource(activityId: Int64) async throws -> RecordEditResourceModel {
        RecordEditResourceModel(
            distance: 15500,
            durationSec: 12000,
            maxElevation: 680,
            mapImageURL: "",
            routes: [
                RecordEditRoute(sequence: 1, name: "서울숲"),
                RecordEditRoute(sequence: 2, name: "한강공원"),
                RecordEditRoute(sequence: 3, name: "남산둘레길")
            ]
        )
    }

    func getWorkoutList(year: Int, month: Int) async throws -> [WorkoutListModel] {
        [
            WorkoutListModel(
                activityId: 1,
                title: "2026.03.19 기록",
                activityDate: "\(year)-\(String(format: "%02d", month))-19",
                timelineImageUrls: []
            ),
            WorkoutListModel(
                activityId: 2,
                title: "레전드 산책 중인 마운틴듀",
                activityDate: "\(year)-\(String(format: "%02d", month))-18",
                timelineImageUrls: []
            ),
            WorkoutListModel(
                activityId: 3,
                title: "한강 러닝",
                activityDate: "\(year)-\(String(format: "%02d", month))-12",
                timelineImageUrls: []
            ),
            WorkoutListModel(
                activityId: 4,
                title: "남산 산책",
                activityDate: "\(year)-\(String(format: "%02d", month))-03",
                timelineImageUrls: []
            )
        ]
    }

    func getActivityStatistics(activityId: Int64) async throws -> TimeLineMetricModel {
        TimeLineMetricModel(
            activityId: activityId,
            title: "2026.03.19 기록",
            activityDate: "2026-03-19",
            distanceMeter: 15500,
            durationSec: 12000,
            maxElevationMeter: 680
        )
    }

    func getActivityTimelineList(activityId: Int64) async throws -> TimeLineData {
        TimeLineData(
            activityId: activityId,
            timelines: [
                TimeLineItemData(
                    timelineId: 1,
                    title: "서울숲",
                    imageUrl: "",
                    createdAt: "2026-03-19T09:30:00"
                ),
                TimeLineItemData(
                    timelineId: 2,
                    title: "한강공원",
                    imageUrl: "",
                    createdAt: "2026-03-19T10:20:00"
                )
            ]
        )
    }

    func getActivityCourseList(activityId: Int64) async throws -> CourseData {
        CourseData(
            activityId: activityId,
            courses: [
                CourseItemData(routeId: 1, name: "서울숲", sequence: 1),
                CourseItemData(routeId: 2, name: "한강공원", sequence: 2),
                CourseItemData(routeId: 3, name: "남산둘레길", sequence: 3)
            ]
        )
    }

    func createActivity(activityType: String, startedAt: String) async throws -> WorkoutRecordStartModel {
        WorkoutRecordStartModel(
            activityId: 1,
            title: "Mock \(activityType)"
        )
    }

    func timeLinePresignedURL(activityId: Int64, fileName: String) async throws -> ImagePresignedURLModel {
        ImagePresignedURLModel(
            presignedURL: "https://mock.routee.local/\(fileName)",
            objectKey: "mock/\(fileName)"
        )
    }

    func uploadTimeLineImage(presignedURL: String, imageData: Data) async throws { }

    func createTimeLine(activityId: Int64, requestDTO: CreateTimeLineRequestDTO) async throws { }

    func backgroundMapPresignedURL(
        activityId: Int64,
        requestDTO: BackgroundMapPresignedURLRequestDTO
    ) async throws -> ImagePresignedURLModel {
        ImagePresignedURLModel(
            presignedURL: "https://mock.routee.local/\(requestDTO.fileName)",
            objectKey: "mock/\(requestDTO.fileName)"
        )
    }

    func finishActivity(activityId: Int64, requestModel: WorkoutRecordFinishModel) async throws { }

    func changeActivityStatus(
        activityId: Int64,
        requestDTO: ChangeActivityStatusRequestDTO
    ) async throws -> ChangeActivityStatusResponseDTO {
        ChangeActivityStatusResponseDTO(
            activityId: activityId,
            status: requestDTO.status
        )
    }

    func updateArchiveActivityTitle(
        activityId: Int64,
        requestDTO: UpdateArchiveActivityTitleRequestDTO
    ) async throws -> UpdateArchiveActivityTitleResponseDTO {
        UpdateArchiveActivityTitleResponseDTO(
            activityId: activityId,
            title: requestDTO.title
        )
    }

    func createCourseList(
        activityId: Int64,
        requestDTO: CreateCourseListRequestDTO
    ) async throws -> CourseListModel {
        CourseListModel(
            activityId: activityId,
            routes: requestDTO.routes.map {
                CourseListModel.RouteData(
                    routeId: $0.routeId,
                    name: $0.name,
                    sequence: $0.sequence
                )
            }
        )
    }
}
