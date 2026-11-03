//
//  ArchiveView.swift
//  Routee-iOS
//
//  Created by 초긍정행운의포춘쿠키 on 7/9/26.
//

import UIKit

import SnapKit

final class ArchiveView: BaseUIView, ToastPresentable {

    // MARK: - UI Properties

    private let backgroundGradientView = RouteeEllipseBackground()
    private let archiveHeaderView = ArchiveHeader()
    private let scrollView = UIScrollView()
    private let contentView = UIView()
    private let profileView = Profile()
    private let monthSelector = ArchiveMonthSelector()
    private let mountainMapView = MountainMap()
    private let calendarView = ArchiveCalendar()

    var onPreviousMonthTap: (() -> Void)? {
        didSet {
            monthSelector.onPreviousTap = onPreviousMonthTap
        }
    }

    var onNextMonthTap: (() -> Void)? {
        didSet {
            monthSelector.onNextTap = onNextMonthTap
        }
    }

    var onSelectDay: ((CalendarCellModel) -> Void)? {
        didSet {
            calendarView.onSelectDay = onSelectDay
        }
    }

    // MARK: - UI Setting

    override func setStyle() {
        backgroundColor = .bg_primary
        scrollView.showsVerticalScrollIndicator = false
        scrollView.contentInsetAdjustmentBehavior = .never
    }

    override func setUI() {
        addSubviews(
            backgroundGradientView,
            archiveHeaderView,
            scrollView
        )
        scrollView.addSubview(contentView)
        contentView.addSubviews(
            profileView,
            monthSelector,
            mountainMapView,
            calendarView
        )
    }

    override func setLayout() {
        backgroundGradientView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
        
        archiveHeaderView.snp.makeConstraints {
            $0.top.equalTo(safeAreaLayoutGuide)
            $0.centerX.equalToSuperview()
            $0.width.equalTo(347)
        }

        scrollView.snp.makeConstraints {
            $0.top.equalTo(archiveHeaderView.snp.bottom)
            $0.horizontalEdges.equalToSuperview()
            $0.bottom.equalTo(safeAreaLayoutGuide)
        }

        contentView.snp.makeConstraints {
            $0.edges.equalTo(scrollView.contentLayoutGuide)
            $0.width.equalTo(scrollView.frameLayoutGuide)
        }

        profileView.snp.makeConstraints {
            $0.top.equalToSuperview()
            $0.centerX.equalToSuperview()
            $0.width.equalTo(343)
            $0.height.equalTo(74)
        }

        monthSelector.snp.makeConstraints {
            $0.top.equalTo(profileView.snp.bottom).offset(22)
            $0.centerX.equalToSuperview()
            $0.width.equalTo(343)
            $0.height.equalTo(26)
        }

        mountainMapView.snp.makeConstraints {
            $0.top.equalTo(monthSelector.snp.bottom).offset(7)
            $0.centerX.equalToSuperview()
            $0.width.equalTo(347)
            $0.height.equalTo(127)
        }

        calendarView.snp.makeConstraints {
            $0.top.equalTo(mountainMapView.snp.bottom).offset(32)
            $0.centerX.equalToSuperview()
            $0.width.equalTo(343)
            $0.height.equalTo(337)
            $0.bottom.equalToSuperview().inset(16)
        }
    }

    // MARK: - Public Methods

    func configureProfile(with model: MemberSummaryModel) {
        profileView.configure(with: model)
    }

    func configureMonthSelector(
        title: String,
        canMoveToPreviousMonth: Bool,
        canMoveToNextMonth: Bool
    ) {
        monthSelector.configure(
            title: title,
            canMoveToPreviousMonth: canMoveToPreviousMonth,
            canMoveToNextMonth: canMoveToNextMonth
        )
    }

    func configureMountainMap(levels: [Int]) {
        mountainMapView.configure(levels: levels)
    }

    func configureCalendar(days: [CalendarCellModel]) {
        calendarView.configure(days: days)
    }
}
