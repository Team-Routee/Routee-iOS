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
    private let finishRecording: () async throws -> Void
    private var hasRequestedFinish = false

    // MARK: - Initializer

    init(
        activityId: Int64?,
        title: String,
        distanceInMeters: Double,
        durationInSeconds: Int,
        maxAltitudeInMeters: Double?,
        backgroundMapImage: UIImage?,
        trackPoints: [TrackPoint],
        photoRecords: [WorkoutPhotoRecord],
        finishRecording: @escaping () async throws -> Void,
        activityRepository: ActivityRepository = DefaultActivityRepository()
    ) {
        self.activityId = activityId
        self.activityRepository = activityRepository
        self.finishRecording = finishRecording
        workoutTimelineView = WorkoutTimeLineView(
            title: title,
            distanceInMeters: distanceInMeters,
            durationInSeconds: durationInSeconds,
            maxAltitudeInMeters: maxAltitudeInMeters,
            backgroundMapImage: backgroundMapImage,
            trackPoints: trackPoints,
            timelineImages: photoRecords.map(\.image),
            timelineLocations: photoRecords.map(\.locationTitle)
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

    // MARK: - Network

    private func completeTimeLine() {
        Task {
            do {
                try await uploadCourseList()
            } catch {
                RouteeLogger.error(error)
            }
            await finishRecordingIfNeeded()
            navigationController?.popToRootViewController(animated: true)
        }
    }

    private func finishRecordingIfNeeded() async {
        guard !hasRequestedFinish else { return }
        hasRequestedFinish = true

        do {
            try await finishRecording()
        } catch {
            RouteeLogger.error(error)
        }
    }

    private func uploadCourseList() async throws {
        guard let activityId else { return }

        let titles = workoutTimelineView.routePointTitles
            .filter { !$0.isEmpty }

        guard !titles.isEmpty else { return }

        let routes = titles.enumerated().map { index, title in
            RouteData(routeId: 0, name: title, sequence: index + 1)
        }

        _ = try await activityRepository.createCourseList(
            activityId: activityId,
            requestDTO: CreateCourseListRequestDTO(routes: routes)
        )
    }

    // MARK: - Actions

    override func setAddTarget() {
        workoutTimelineView.goToEditButton.addTarget(self, action: #selector(didTapGoToEditButton), for: .touchUpInside)
    }

    @objc
    private func didTapGoToEditButton() {
        Task {
            await finishRecordingIfNeeded()
            navigationController?.pushViewController(EditorViewController(), animated: true)
        }
    }
}
