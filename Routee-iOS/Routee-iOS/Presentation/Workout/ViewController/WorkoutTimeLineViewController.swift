//
//  WorkoutTimeLineViewController.swift
//  Routee-iOS
//
//  Created by LEESANGYUP on 7/11/26.
//

import UIKit

final class WorkoutTimeLineViewController: BaseUIViewController {
    private let workoutTimelineView: WorkoutTimeLineView
    private let activityId: Int64?
    private let activityRepository: ActivityRepository
    private let finishRecording: (String) async throws -> Void
    private let showFailureModalOnAppear: Bool
    private let hasRecordedRoute: Bool
    private var isCompletingTimeline = false
    private var didShowFailureModal = false
    private var didTrackRecordingEnded = false

    // MARK: - Initializer

    init(
        activityId: Int64?,
        title: String,
        distanceInMeters: Double,
        durationInSeconds: Int,
        maxAltitudeInMeters: Double?,
        trackPoints: [TrackPoint],
        photoRecords: [WorkoutPhotoRecord],
        finishRecording: @escaping (String) async throws -> Void,
        showFailureModalOnAppear: Bool,
        activityRepository: ActivityRepository = DefaultActivityRepository()
    ) {
        self.activityId = activityId
        self.activityRepository = activityRepository
        self.finishRecording = finishRecording
        self.showFailureModalOnAppear = showFailureModalOnAppear
        hasRecordedRoute = trackPoints.count >= 2
        workoutTimelineView = WorkoutTimeLineView(
            title: title,
            distanceInMeters: distanceInMeters,
            durationInSeconds: durationInSeconds,
            maxAltitudeInMeters: maxAltitudeInMeters,
            trackPoints: trackPoints,
            photoRecords: photoRecords
        )
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Life Cycle

    override func loadView() {
        view = workoutTimelineView

        workoutTimelineView.completeButtonAction = { [weak self] in
            self?.completeTimeLine()
        }
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        workoutTimelineView.fitTrackMapToRoute()

        if let activityId, !didTrackRecordingEnded {
            didTrackRecordingEnded = true
            AnalyticsTracker.track(
                .workoutRecordingEnded,
                properties: [
                    "activity_id": String(activityId),
                    "activity_type": "HIKING"
                ]
            )
        }

        guard !didShowFailureModal else { return }

        guard hasRecordedRoute else {
            didShowFailureModal = true
            presentMissingRouteFailureModal()
            return
        }

        guard showFailureModalOnAppear else { return }
        didShowFailureModal = true
        presentMissingNetworkFailureModal()
    }

    // MARK: - Network

    private func completeTimeLine() {
        guard !isCompletingTimeline else { return }
        guard hasRecordedRoute else {
            presentMissingRouteFailureModal()
            return
        }

        isCompletingTimeline = true

        Task {
            do {
                try await saveRecording()
                _ = navigationController?.popToRootViewController(animated: true)
            } catch {
                isCompletingTimeline = false
                RouteeLogger.error(error)
                presentMissingNetworkFailureModal()
            }
        }
    }

    private func saveRecording() async throws {
        try await LoadingOverlayManager.shared.perform(
            message: "데이터를 불러오고 있어요"
        ) {
            try await self.uploadCourseList()
            try await self.saveWorkoutRecord()
        }
    }

    private func saveWorkoutRecord() async throws {
        workoutTimelineView.endEditing(true)
        let title = workoutTimelineView.activityTitle
        try await finishRecording(title)

        if let activityId {
            AnalyticsTracker.track(
                .workoutCompleted,
                properties: [
                    "activity_id": String(activityId),
                    "activity_type": "HIKING"
                ]
            )
        }
    }

    private func uploadCourseList() async throws {
        guard let activityId else { return }

        let titles = await MainActor.run {
            self.workoutTimelineView.routePointTitles
                .filter { !$0.isEmpty }
        }

        guard !titles.isEmpty else { return }

        let routes = titles.enumerated().map { index, title in
            RouteData(routeId: 0, name: title, sequence: index + 1)
        }

        _ = try await activityRepository.createCourseList(
            activityId: activityId,
            requestDTO: CreateCourseListRequestDTO(routes: routes)
        )
    }

    // MARK: - Private Method

    private func presentMissingNetworkFailureModal() {
        if let activityId {
            AnalyticsTracker.track(
                .workoutCompleteFailed,
                properties: [
                    "activity_id": String(activityId),
                    "activity_type": "HIKING"
                ]
            )
        }

        let confirmAction: () -> Void = { [weak self] in
            self?.navigationController?.popToRootViewController(animated: true)
        }

        let modal = ActionPrimaryModal(
            title: "기록 등록 실패",
            description: """
            인터넷 연결이 불안정해서
            기록이 등록되지 않았어요.
            연결이 안정되면 다시 기록해주세요.

            (인터넷 연결 오프라인 상태)
            """,
            actionCount: .single,
            leftButtonTitle: "확인",
            leftButtonAction: confirmAction
        )

        present(modal, animated: true)
    }

    private func presentMissingRouteFailureModal() {
        let confirmAction: () -> Void = { [weak self] in
            self?.navigationController?.popToRootViewController(animated: true)
        }

        let modal = ActionPrimaryModal(
            title: "기록 등록 실패",
            description: """
            운동 경로를 확인할 수 없어
            기록이 등록되지 않았어요.
            위치 정보를 확인한 후 다시 시도해주세요.
            """,
            actionCount: .single,
            leftButtonTitle: "확인",
            leftButtonAction: confirmAction
        )

        present(modal, animated: true)
    }

    // MARK: - Actions

    override func setAddTarget() {
        workoutTimelineView.goToEditButton.addTarget(self, action: #selector(didTapGoToEditButton), for: .touchUpInside)
    }

    @objc
    private func didTapGoToEditButton() {
        guard !isCompletingTimeline else { return }
        guard hasRecordedRoute else {
            presentMissingRouteFailureModal()
            return
        }

        isCompletingTimeline = true

        Task {
            do {
                try await saveRecording()
                navigationController?.pushViewController(
                    EditorViewController(
                        activityId: activityId,
                        entryPoint: .postWorkout
                    ),
                    animated: true
                )
                isCompletingTimeline = false
            } catch {
                isCompletingTimeline = false
                RouteeLogger.error(error)
                presentMissingNetworkFailureModal()
            }
        }
    }
}
