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

    var backButtonAction: (() -> Void)? {
        get { navigationBar.backButtonAction }
        set { navigationBar.backButtonAction = newValue }
    }

    var completeButtonAction: (() -> Void)? {
        get { navigationBar.rightButtonAction }
        set { navigationBar.rightButtonAction = newValue }
    }
    
    private let title: String
    private let distance: String
    private let time: String
    private let altitude: String
    private let backgroundMapImage: UIImage?
    private let trackPoints: [TrackPoint]
    private let timelineImages: [UIImage]
    private let timelineLocations: [String?]

    // MARK: - Initializer

    init(
        title: String,
        distanceInMeters: Double,
        durationInSeconds: Int,
        maxAltitudeInMeters: Double?,
        backgroundMapImage: UIImage?,
        trackPoints: [TrackPoint],
        timelineImages: [UIImage],
        timelineLocations: [String?]
    ) {
        self.title = title
        self.distance = String(format: "%.2f", distanceInMeters / 1_000)

        let hours = durationInSeconds / 3_600
        let minutes = (durationInSeconds % 3_600) / 60
        self.time = String(format: "%02d:%02d", hours, minutes)

        self.altitude = maxAltitudeInMeters.map { String(Int($0.rounded())) } ?? "0"
        self.backgroundMapImage = backgroundMapImage
        self.trackPoints = trackPoints
        self.timelineImages = timelineImages
        self.timelineLocations = timelineLocations

        super.init(frame: .zero)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - UI Properties
    
    private let backgroundGradiant = RouteeEllipseBackground()
    private let scrollView = UIScrollView()
    private let navigationBar = TopNavigationBar(rightTitle: "완료")
    private lazy var titleTextField = TitleTextField(title: title, showsEditIcon: true)
    private lazy var workoutMetric = WorkoutMetric(distance: distance, time: time, altitude: altitude)
    private lazy var trackMap = TrackMap(
        backgroundImage: backgroundMapImage ?? UIImage(resource: .imgNavermapMain),
        trackPoints: trackPoints
    )
    private let timeLineStackView = UIStackView()
    private let timeLineLabel = UILabel()
    private let timeLineDateLabel = UILabel()
    private lazy var timeLineCard = TimeLineCard(images: timelineImages, locations: timelineLocations)
    private let myRoute = MyRoute(mode: .write)
    lazy var goToEditButton = RouteeButton(titleText: "기록 편집 바로가기", type: .enabled)
    
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
        timeLineStackView.isHidden = timelineImages.isEmpty
        timeLineCard.isHidden = timelineImages.isEmpty

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
            let formatter = DateFormatter()
            formatter.dateFormat = "yyyy.MM.dd"
            $0.text = formatter.string(from: Date())
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
            if timelineImages.isEmpty {
                $0.top.equalTo(trackMap.snp.bottom).offset(48)
            } else {
                $0.top.equalTo(timeLineCard.snp.bottom).offset(61)
            }
            $0.horizontalEdges.equalToSuperview().inset(16)
            $0.bottom.equalTo(scrollView.contentLayoutGuide).inset(140)
        }
        
        goToEditButton.snp.makeConstraints {
            $0.bottom.equalTo(safeAreaLayoutGuide).inset(28)
            $0.centerX.equalToSuperview()
        }
    }
}
