//
//  WorkoutTimeLineView.swift
//  Routee-iOS
//
//  Created by LEESANGYUP on 7/10/26.
//

import UIKit

import SnapKit
import Then

final class WorkoutTimeLineView: BaseUIView {
    
    // MARK: - Properties
    
    private let title = "2026.07.09 기록"
    private let distance = "15.53"
    private let time = "03:20"
    private let altitude = "2132"
    var trackPoints: [TrackPoint] = TrackPoint.dummyTrackPoints()
    var timelineImages: [String] = [
        "img_location1", "img_location2", "img_location3", "img_location4", "img_location5", "img_location6"
    ]
    
    // MARK: - UI Properties
    
    private let backgroundGradiant = RouteeEllipseBackground()
    private let scrollView = UIScrollView()
    private let navigationBar = TopNavigationBar(rightTitle: "완료")
    private lazy var titleTextField = TitleTextField(title: title, showsEditIcon: true)
    private lazy var workoutMetric = WorkoutMetric(distance: distance, time: time, altitude: altitude)
    private lazy var trackMap = TrackMap(backgroundImage: UIImage(resource: .imgNavermapMain), trackPoints: trackPoints)
    private let timeLineStackView = UIStackView()
    private let timeLineLabel = UILabel()
    private let timeLineDateLabel = UILabel()
    private lazy var timeLineCard = TimeLineCard(imageNames: timelineImages)
    private let myRoute = MyRoute(mode: .write)
    private lazy var goToEditButton = RouteeButton(titleText: "기록 편집 바로가기", type: .enabled)
    
    // MARK: - UI Setting
    
    override func setUI() {
        addSubviews(
            backgroundGradiant,
            navigationBar,
            scrollView,
            goToEditButton
        )
        
        scrollView.addSubviews(
            titleTextField,
            workoutMetric,
            trackMap,
            timeLineStackView,
            timeLineCard,
            myRoute
        )
        
        timeLineStackView.addArrangedSubviews(timeLineLabel, timeLineDateLabel)
    }
    
    override func setStyle() {
        timeLineStackView.do {
            $0.axis = .vertical
            $0.spacing = 4
        }
        
        timeLineLabel.do {
            $0.text = "타임라인"
            $0.font = .title_sb_18
            $0.textColor = .staticWhite
        }
        
        timeLineDateLabel.do {
            $0.text = "2026.07.11"
            $0.font = .label_m_12
            $0.textColor = .grey200
        }
    }
    
    override func setLayout() {
        backgroundGradiant.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
        
        navigationBar.snp.makeConstraints {
            $0.top.equalTo(safeAreaLayoutGuide)
            $0.horizontalEdges.equalToSuperview()
        }
        
        scrollView.snp.makeConstraints {
            $0.top.equalTo(navigationBar.snp.bottom)
            $0.horizontalEdges.equalToSuperview()
            $0.bottom.equalToSuperview()
        }
        
        titleTextField.snp.makeConstraints {
            $0.top.equalTo(scrollView.contentLayoutGuide).offset(8)
            $0.horizontalEdges.equalTo(scrollView.contentLayoutGuide)
            $0.width.equalTo(scrollView.frameLayoutGuide)
        }
        
        workoutMetric.snp.makeConstraints {
            $0.top.equalTo(titleTextField.snp.bottom).offset(8)
            $0.horizontalEdges.equalToSuperview().inset(16)
            $0.width.greaterThanOrEqualTo(343)
            $0.height.equalTo(91)
        }
        
        trackMap.snp.makeConstraints {
            $0.top.equalTo(workoutMetric.snp.bottom).offset(8)
            $0.horizontalEdges.equalToSuperview().inset(16)
            $0.width.greaterThanOrEqualTo(343)
            $0.height.equalTo(481)
        }
        
        timeLineStackView.snp.makeConstraints {
            $0.top.equalTo(trackMap.snp.bottom).offset(48)
            $0.horizontalEdges.equalTo(scrollView.contentLayoutGuide).inset(16)
        }
        
        timeLineCard.snp.makeConstraints {
            $0.top.equalTo(timeLineStackView.snp.bottom).offset(16)
            $0.centerX.equalToSuperview()
            $0.width.equalToSuperview()
        }
        
        myRoute.snp.makeConstraints {
            $0.top.equalTo(timeLineCard.snp.bottom).offset(61)
            $0.horizontalEdges.equalToSuperview().inset(16)
            $0.bottom.equalTo(scrollView.contentLayoutGuide).inset(140)
        }
        
        goToEditButton.snp.makeConstraints {
            $0.bottom.equalTo(safeAreaLayoutGuide).inset(28)
            $0.centerX.equalToSuperview()
        }
    }
}
