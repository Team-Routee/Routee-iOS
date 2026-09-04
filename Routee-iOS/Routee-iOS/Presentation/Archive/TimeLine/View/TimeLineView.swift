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

    var titleEditingDidEnd: ((String) -> Void)? {
        get { titleTextField.editingDidEnd }
        set { titleTextField.editingDidEnd = newValue }
    }

    private let record: ActivityListModel?
    private var didConfigureTimeLine = false
    private var didConfigureCourse = false
    private var showsTimeLineSection = false
    private var showsMyRouteSection = false

    // MARK: - UI Properties

    private let topNavigationBar = TopNavigationBar()
    private let backgroundGradientView = RouteeEllipseBackground()
    private let scrollView = UIScrollView()
    private let contentView = UIView()
    private lazy var titleTextField = TitleTextField(
        title: record?.title ?? "",
        showsEditIcon: true
    )
    private let trackMap = TimelineTrackMap()
    private let workoutMetric = WorkoutMetric(distance: "", time: "", altitude: "")
    private let timelineTitleLabel = UILabel()
    private let timelineDateLabel = UILabel()
    private let timelineCard = TimeLineCard(imageNames: [])
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

    // MARK: - Public Methods

    func configureMetric(with viewModel: TimeLineMetricViewModel) {
        workoutMetric.updateDistance(viewModel.distance)
        workoutMetric.updateTime(viewModel.time)
        workoutMetric.updateMaximumAltitude(viewModel.altitude)
    }

    func configureTrackMap(with model: ActivityEditorModel) {
        trackMap.updateRoute(
            trackPoints: model.trackPoints,
            markers: model.timelineMarkers
        )
    }

    func configureTimeLineList(with model: TimeLineData) {
        didConfigureTimeLine = true
        showsTimeLineSection = !model.imageUrls.filter { !$0.isEmpty }.isEmpty
        timelineDateLabel.text = model.timelines.first.map {
            String($0.createdAt.prefix(10))
                .replacingOccurrences(of: "-", with: ".")
        }

        if showsTimeLineSection {
            timelineCard.configure(
                imageUrls: model.imageUrls,
                locations: model.locations
            )
        }
        updateContentVisibility()
    }

    func configureCourseList(with model: CourseData) {
        let routePoint = RoutePointModel(
            points: model.routePoint.points.filter { !$0.isEmpty }
        )
        didConfigureCourse = true
        showsMyRouteSection = !routePoint.points.isEmpty

        if showsMyRouteSection {
            myRoute.configure(mode: .read, routePoint: routePoint)
        }
        updateContentVisibility()
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
            $0.text = ""
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
            trackMap,
            timelineTitleLabel,
            timelineDateLabel,
            timelineCard,
            myRoute,
            emptyStateLabel
        )
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
            $0.top.equalToSuperview()
            $0.horizontalEdges.equalToSuperview()
        }

        workoutMetric.snp.makeConstraints {
            $0.top.equalTo(titleTextField.snp.bottom).offset(8)
            $0.centerX.equalTo(scrollView.frameLayoutGuide)
            $0.width.equalTo(343)
            $0.height.equalTo(91)
        }

        trackMap.snp.makeConstraints {
            $0.top.equalTo(workoutMetric.snp.bottom).offset(7)
            $0.centerX.equalTo(scrollView.frameLayoutGuide)
            $0.width.equalTo(343)
            $0.height.equalTo(480)
        }

        timelineTitleLabel.snp.makeConstraints {
            $0.top.equalTo(trackMap.snp.bottom).offset(48)
            $0.centerX.equalTo(scrollView.frameLayoutGuide)
            $0.width.equalTo(343)
            $0.height.equalTo(25)
        }

        timelineDateLabel.snp.makeConstraints {
            $0.top.equalTo(timelineTitleLabel.snp.bottom).offset(4)
            $0.centerX.equalTo(scrollView.frameLayoutGuide)
            $0.width.equalTo(343)
            $0.height.equalTo(17)
        }

        timelineCard.snp.makeConstraints {
            $0.top.equalTo(timelineDateLabel.snp.bottom).offset(16)
            $0.horizontalEdges.equalToSuperview()
            $0.height.equalTo(timelineCard.snp.width)
        }

        myRoute.snp.makeConstraints {
            $0.top.equalTo(timelineCard.snp.bottom).offset(82)
            $0.centerX.equalTo(scrollView.frameLayoutGuide)
            $0.width.equalTo(343)
            $0.bottom.equalToSuperview().inset(64)
        }

        emptyStateLabel.snp.makeConstraints {
            $0.top.equalTo(trackMap.snp.bottom).offset(28)
            $0.centerX.equalToSuperview()
            $0.height.equalTo(20)
            $0.bottom.equalToSuperview().inset(64)
        }

        updateContentVisibility()
    }

    // MARK: - Private Methods

    private func updateContentVisibility() {
        let shouldShowEmptyState = didConfigureTimeLine
            && didConfigureCourse
            && !showsTimeLineSection
            && !showsMyRouteSection

        timelineTitleLabel.isHidden = !showsTimeLineSection
        timelineDateLabel.isHidden = !showsTimeLineSection
        timelineCard.isHidden = !showsTimeLineSection
        myRoute.isHidden = !showsMyRouteSection
        emptyStateLabel.isHidden = !shouldShowEmptyState

        updateTimeLineCardLayout()
        updateMyRouteLayout()
        updateEmptyStateLayout()
    }

    private func updateTimeLineCardLayout() {
        timelineCard.snp.remakeConstraints {
            $0.top.equalTo(timelineDateLabel.snp.bottom).offset(16)
            $0.horizontalEdges.equalToSuperview()
            $0.height.equalTo(timelineCard.snp.width)
        }
    }

    private func updateMyRouteLayout() {
        myRoute.snp.remakeConstraints {
            if showsTimeLineSection {
                let topOffset = showsMyRouteSection ? 82 : 0
                $0.top.equalTo(timelineCard.snp.bottom).offset(topOffset)
            } else {
                $0.top.equalTo(trackMap.snp.bottom).offset(28)
            }
            $0.centerX.equalTo(scrollView.frameLayoutGuide)
            $0.width.equalTo(343)

            if showsMyRouteSection {
                $0.bottom.equalToSuperview().inset(64)
            } else if showsTimeLineSection {
                $0.height.equalTo(0)
                $0.bottom.equalToSuperview().inset(64)
            }
        }
    }

    private func updateEmptyStateLayout() {
        emptyStateLabel.snp.remakeConstraints {
            $0.top.equalTo(trackMap.snp.bottom).offset(28)
            $0.centerX.equalToSuperview()
            $0.height.equalTo(20)

            if !showsTimeLineSection && !showsMyRouteSection {
                $0.bottom.equalToSuperview().inset(64)
            }
        }
    }
}
