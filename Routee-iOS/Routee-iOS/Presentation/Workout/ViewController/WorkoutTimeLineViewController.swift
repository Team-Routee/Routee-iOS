//
//  WorkoutTimeLineViewController.swift
//  Routee-iOS
//
//  Created by LEESANGYUP on 7/11/26.
//

import UIKit

final class WorkoutTimeLineViewController: BaseUIViewController {
    private let workoutTimelineView: WorkoutTimeLineView

    // MARK: - Initializer

    init(
        title: String,
        distanceInMeters: Double,
        durationInSeconds: Int,
        maxAltitudeInMeters: Double?,
        backgroundMapImage: UIImage?,
        trackPoints: [TrackPoint],
        photoRecords: [WorkoutPhotoRecord]
    ) {
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

        workoutTimelineView.backButtonAction = { [weak self] in
            self?.navigationController?.popToRootViewController(animated: true)
        }

        workoutTimelineView.completeButtonAction = { [weak self] in
            self?.navigationController?.popToRootViewController(animated: true)
        }
    }

    // MARK: - Actions

    override func setAddTarget() {
        workoutTimelineView.goToEditButton.addTarget(self, action: #selector(didTapGoToEditButton), for: .touchUpInside)
    }

    @objc
    private func didTapGoToEditButton() {
        self.navigationController?.pushViewController(EditorViewController(), animated: true)
    }
}
