//
//  TimeLineView.swift
//  Routee-iOS
//
//  Created by 초긍정행운의포춘쿠키 on 7/12/26.
//

import UIKit

import SnapKit
import Then

final class TimeLineView: BaseUIView {

    // MARK: - Properties

    var backButtonAction: (() -> Void)? {
        get { topNavigationBar.backButtonAction }
        set { topNavigationBar.backButtonAction = newValue }
    }

    private let trackPoints = TrackPoint.dummyTrackPoints()
    private let timelineImages = [
        "img_location1",
        "img_location2",
        "img_location3",
        "img_location4",
        "img_location5"
    ]
    private let timelineLocations = [
        "창의문",
        "청운대",
        "말바위",
        nil,
        "창의문"
    ]

    // MARK: - UI Properties

    private let topNavigationBar = TopNavigationBar()
    private let scrollView = UIScrollView()
    private let contentView = UIView()
    private let titleTextField = TitleTextField(title: "숭실대 동기모임 북한산", showsEditIcon: false)
    private let workoutMetric = WorkoutMetric(distance: "15.53", time: "03:20", altitude: "2132")
    private lazy var trackMap = TrackMap(
        backgroundImage: UIImage(resource: .imgNavermapMain),
        trackPoints: trackPoints
    )
    private let timelineTitleLabel = UILabel()
    private let timelineDateLabel = UILabel()
    private lazy var timelineCard = TimeLineCard(
        imageNames: timelineImages,
        locations: timelineLocations
    )
    private let myRouteView = RouteView(mode: .read)

    // MARK: - UI Setting

    override func setStyle() {
        backgroundColor = .bg_primary

        scrollView.do {
            $0.showsVerticalScrollIndicator = false
            $0.contentInsetAdjustmentBehavior = .never
        }

        timelineTitleLabel.do {
            $0.text = "타임라인"
            $0.font = .title_sb_18
            $0.textColor = .static_white
        }

        timelineDateLabel.do {
            $0.text = "2026.03.12"
            $0.font = .label_m_12
            $0.textColor = .grey_300
        }
    }

    override func setUI() {
        addSubviews(topNavigationBar, scrollView)
        scrollView.addSubview(contentView)
        contentView.addSubviews(
            titleTextField,
            workoutMetric,
            trackMap,
            timelineTitleLabel,
            timelineDateLabel,
            timelineCard,
            myRouteView
        )
    }

    override func setLayout() {
        topNavigationBar.snp.makeConstraints {
            $0.top.equalTo(safeAreaLayoutGuide)
            $0.horizontalEdges.equalToSuperview()
        }

        scrollView.snp.makeConstraints {
            $0.top.equalTo(topNavigationBar.snp.bottom)
            $0.horizontalEdges.bottom.equalToSuperview()
        }

        contentView.snp.makeConstraints {
            $0.edges.equalTo(scrollView.contentLayoutGuide)
            $0.width.equalTo(scrollView.frameLayoutGuide)
        }

        titleTextField.snp.makeConstraints {
            $0.top.equalToSuperview().offset(4)
            $0.horizontalEdges.equalToSuperview()
        }

        workoutMetric.snp.makeConstraints {
            $0.top.equalTo(titleTextField.snp.bottom).offset(8)
            $0.horizontalEdges.equalToSuperview().inset(16)
            $0.height.equalTo(91)
        }

        trackMap.snp.makeConstraints {
            $0.top.equalTo(workoutMetric.snp.bottom).offset(8)
            $0.horizontalEdges.equalToSuperview().inset(16)
            $0.height.equalTo(481)
        }

        timelineTitleLabel.snp.makeConstraints {
            $0.top.equalTo(trackMap.snp.bottom).offset(48)
            $0.horizontalEdges.equalToSuperview().inset(16)
            $0.height.equalTo(25)
        }

        timelineDateLabel.snp.makeConstraints {
            $0.top.equalTo(timelineTitleLabel.snp.bottom).offset(4)
            $0.horizontalEdges.equalToSuperview().inset(16)
            $0.height.equalTo(17)
        }

        timelineCard.snp.makeConstraints {
            $0.top.equalTo(timelineDateLabel.snp.bottom).offset(20)
            $0.horizontalEdges.equalToSuperview()
        }

        myRouteView.snp.makeConstraints {
            $0.top.equalTo(timelineCard.snp.bottom).offset(82)
            $0.horizontalEdges.equalToSuperview().inset(16)
            $0.bottom.equalToSuperview().inset(64)
        }
    }
}
