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

    private let record: ActivityListModel?
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
    private var showTimelineCard: Bool {
        guard let record else { return true }
        return record.thumbnailUrl != nil
    }
    private let showMyRoute: Bool = true

    // MARK: - UI Properties

    private let topNavigationBar = TopNavigationBar()
    private let backgroundGradientView = RouteeEllipseBackground()
    private let scrollView = UIScrollView()
    private let contentView = UIView()
    private lazy var titleTextField = TitleTextField(
        title: record?.title ?? "숭실대 동기모임 북한산",
        showsEditIcon: false
    )
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
    private let myRoute = MyRoute(mode: .read)
    private let emptyStateLabel = UILabel()

    // MARK: - Initializer

    init(record: ActivityListModel? = nil) {
        self.record = record
        super.init(frame: .zero)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

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
            $0.textColor = .grey_200
        }
        
        emptyStateLabel.do {
            $0.text = "기록된 루트가 없습니다"
            $0.font = .label_m_14
            $0.textColor = .grey_200
        }
    }

    override func setUI() {
        addSubviews(backgroundGradientView, topNavigationBar, scrollView)
        scrollView.addSubview(contentView)
        contentView.addSubviews(
            titleTextField,
            workoutMetric,
            trackMap
        )

        if showTimelineCard {
            contentView.addSubviews(timelineTitleLabel,
                                    timelineDateLabel,
                                    timelineCard)
        }

        if showMyRoute {
            contentView.addSubview(myRoute)
        } else {
            contentView.addSubview(emptyStateLabel)
        }
    }

    override func setLayout() {
        backgroundGradientView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
        
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
            $0.top.leading.equalToSuperview()
        }

        workoutMetric.snp.makeConstraints {
            $0.top.equalTo(titleTextField.snp.bottom).offset(8)
            $0.horizontalEdges.equalToSuperview().inset(16)
            $0.height.equalTo(91)
        }

        trackMap.snp.makeConstraints {
            $0.top.equalTo(workoutMetric.snp.bottom).offset(7)
            $0.horizontalEdges.equalToSuperview().inset(16)
            $0.height.equalTo(480)
        }

        if showTimelineCard {
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
                $0.top.equalTo(timelineDateLabel.snp.bottom).offset(16)
                $0.horizontalEdges.equalToSuperview()
            }
        }

        if showMyRoute {
            myRoute.snp.makeConstraints {
                if showTimelineCard {
                    $0.top.equalTo(timelineCard.snp.bottom).offset(82)
                } else {
                    $0.top.equalTo(trackMap.snp.bottom).offset(28)
                }
                $0.horizontalEdges.equalToSuperview().inset(16)
                $0.bottom.equalToSuperview().inset(64)
            }
        } else {
            emptyStateLabel.snp.makeConstraints {
                if showTimelineCard {
                    $0.top.equalTo(timelineCard.snp.bottom).offset(48)
                } else {
                    $0.top.equalTo(trackMap.snp.bottom).offset(28)
                }
                $0.centerX.equalToSuperview()
                $0.height.equalTo(20)
                $0.bottom.equalToSuperview().inset(64)
            }
        }
    }
}
