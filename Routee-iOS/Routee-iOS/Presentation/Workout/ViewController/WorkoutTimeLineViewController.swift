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
    private var savedActivityTitle: String
    private var savedRoutes: [RouteData]
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
        courseRoutes: [CourseListModel.RouteData],
        showFailureModalOnAppear: Bool,
        activityRepository: ActivityRepository = DefaultActivityRepository()
    ) {
        self.activityId = activityId
        self.activityRepository = activityRepository
        savedActivityTitle = title
        savedRoutes = courseRoutes.sorted { $0.sequence < $1.sequence }.map {
            RouteData(routeId: $0.routeId, name: $0.name, sequence: $0.sequence)
        }
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

        Task { @MainActor in
            do {
                try await saveTimelineChanges()
                _ = navigationController?.popToRootViewController(animated: true)
            } catch {
                isCompletingTimeline = false
                RouteeLogger.error(error)
                presentMissingNetworkFailureModal()
            }
        }
    }

    private func saveTimelineChanges() async throws {
        workoutTimelineView.endEditing(true)
        try await LoadingOverlayManager.shared.perform {
            try await self.updateCourseList()
            try await self.updateActivityTitle()
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

    private func updateActivityTitle() async throws {
        let title = workoutTimelineView.activityTitle
        guard title != savedActivityTitle else { return }
        guard let activityId else { throw RouteeError.noData }

        _ = try await activityRepository.updateArchiveActivityTitle(
            activityId: activityId,
            requestDTO: UpdateArchiveActivityTitleRequestDTO(title: title)
        )
        savedActivityTitle = title
    }

    private func currentRoutes() -> [RouteData] {
        let titles = workoutTimelineView.routePointTitles
        let routeIds = workoutTimelineView.routePointIds
        var routes: [RouteData] = []
        for index in titles.indices {
            let title = titles[index].trimmingCharacters(in: .whitespacesAndNewlines)
            guard !title.isEmpty else { continue }
            routes.append(RouteData(routeId: routeIds[index], name: title, sequence: routes.count + 1))
        }
        return routes
    }

    private func updateCourseList() async throws {
        let routes = currentRoutes()
        let hasChanges = routes.count != savedRoutes.count || zip(routes, savedRoutes).contains {
            $0.routeId != $1.routeId || $0.name != $1.name || $0.sequence != $1.sequence
        }
        guard hasChanges else { return }
        guard let activityId else { throw RouteeError.noData }

        let response = try await activityRepository.updateCourseList(
            activityId: activityId,
            requestDTO: UpdateCourseListRequestDTO(routes: routes)
        )
        var routeIds = workoutTimelineView.routePointIds
        var sequence = 0
        for (index, title) in workoutTimelineView.routePointTitles.enumerated() {
            guard !title.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else { continue }
            sequence += 1
            if let route = response.routes.first(where: { $0.sequence == sequence }) {
                routeIds[index] = route.routeId
            }
        }
        workoutTimelineView.updateRouteIds(routeIds)
        savedRoutes = currentRoutes()
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
                isCompletingTimeline = false
            } catch {
                isCompletingTimeline = false
                RouteeLogger.error(error)
                presentMissingNetworkFailureModal()
            }
        }
    }
}
