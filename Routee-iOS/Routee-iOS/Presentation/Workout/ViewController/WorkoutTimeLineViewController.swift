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
    private let viewModel: WorkoutTimeLineViewModel
    private let showFailureModalOnAppear: Bool
    private let hasRecordedRoute: Bool
    private var isUpdatingActivity = false
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
        courseRoutes: [CourseListModel.RouteData],
        showFailureModalOnAppear: Bool,
        activityRepository: ActivityRepository = DefaultActivityRepository()
    ) {
        self.activityId = activityId
        viewModel = WorkoutTimeLineViewModel(
            title: title,
            courseRoutes: courseRoutes,
            activityRepository: activityRepository
        )
        self.showFailureModalOnAppear = showFailureModalOnAppear
        hasRecordedRoute = trackPoints.count >= 2
        workoutTimelineView = WorkoutTimeLineView(
            title: title,
            distanceInMeters: distanceInMeters,
            durationInSeconds: durationInSeconds,
            maxAltitudeInMeters: maxAltitudeInMeters,
            trackPoints: trackPoints,
            photoRecords: photoRecords,
            courseRoutes: courseRoutes
        )
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Life Cycle
    
    override func loadView() {
        view = workoutTimelineView
        
        workoutTimelineView.backButtonAction = { [weak self] in
            self?.presentActivityDeleteModal()
        }

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
        guard !isUpdatingActivity else { return }
        guard hasRecordedRoute else {
            presentMissingRouteFailureModal()
            return
        }
        
        isUpdatingActivity = true
        
        Task { @MainActor in
            do {
                try await saveTimelineChanges()
                _ = navigationController?.popToRootViewController(animated: true)
            } catch {
                isUpdatingActivity = false
                RouteeLogger.error(error)
                presentMissingNetworkFailureModal()
            }
        }
    }
    
    private func deleteActivityAndExit() {
        guard !isUpdatingActivity else { return }
        guard let activityId else {
            navigationController?.popToRootViewController(animated: true)
            return
        }

        isUpdatingActivity = true

        Task {
            do {
                try await LoadingOverlayManager.shared.perform {
                    try await self.viewModel.deleteActivity(activityId: activityId)
                }
                navigationController?.popToRootViewController(animated: true)
            } catch {
                isUpdatingActivity = false
                RouteeLogger.error(error)
            }
        }
    }

    private func saveTimelineChanges() async throws {
        workoutTimelineView.endEditing(true)
        try await LoadingOverlayManager.shared.perform {
            if let routeIds = try await self.viewModel.updateCourseList(
                activityId: self.activityId,
                titles: self.workoutTimelineView.routePointTitles,
                routeIds: self.workoutTimelineView.routePointIds
            ) {
                self.workoutTimelineView.updateRouteIds(routeIds)
            }
            try await self.viewModel.updateActivityTitle(
                activityId: self.activityId,
                title: self.workoutTimelineView.activityTitle
            )
        }
        
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
    
    private func presentActivityDeleteModal() {
        guard !isUpdatingActivity, presentedViewController == nil else { return }

        let modal = ActionPrimaryModal(
            title: """
            기록을 저장하지 않고
            나가시겠습니까?
            """,
            description: """
            운동 기록이 저장되지 않고,
            기록을 복구할 수 없습니다.
            """,
            actionCount: .double,
            leftButtonTitle: "취소",
            rightButtonTitle: "나가기",
            rightButtonAction: { [weak self] in
                self?.deleteActivityAndExit()
            }
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
        guard !isUpdatingActivity else { return }
        guard hasRecordedRoute else {
            presentMissingRouteFailureModal()
            return
        }
        
        isUpdatingActivity = true
        
        Task { @MainActor in
            do {
                try await saveTimelineChanges()
                navigationController?.pushViewController(
                    EditorViewController(
                        activityId: activityId,
                        entryPoint: .postWorkout
                    ),
                    animated: true
                )
                isUpdatingActivity = false
            } catch {
                isUpdatingActivity = false
                RouteeLogger.error(error)
                presentMissingNetworkFailureModal()
            }
        }
    }
}
