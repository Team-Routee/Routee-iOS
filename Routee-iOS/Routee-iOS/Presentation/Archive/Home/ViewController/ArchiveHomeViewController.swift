//
// ArchiveViewController.swift
//  Routee-iOS
//
//  Created by 초긍정행운의포춘쿠키 on 7/7/26.
//

import UIKit

import SnapKit
import Then

final class ArchiveHomeViewController: BaseUIViewController {

    // MARK: - Properties

    private var year = Calendar.current.component(.year, from: Date())
    private var month = Calendar.current.component(.month, from: Date())

    // MARK: - UI Properties

    private let archiveHeaderView = ArchiveHeaderView()
    private let profileView = ProfileView()
    private let monthSelector = ArchiveMonthSelector()
    private let mountainMapView = MountainMapView()
    private let calendarView = CalendarView()

    // MARK: - Life Cycle

    override func viewDidLoad() {
        super.viewDidLoad()

        setStyle()
        setUI()
        setLayout()
        setDelegate()
        loadDummyData()
    }

    // MARK: - UI Setting

    private func setStyle() {
        view.backgroundColor = .bg_primary
    }

    private func setUI() {
        view.addSubviews(
            archiveHeaderView,
            profileView,
            monthSelector,
            mountainMapView,
            calendarView
        )
    }

    private func setLayout() {
        archiveHeaderView.snp.makeConstraints {
            $0.top.equalTo(view.safeAreaLayoutGuide)
            $0.leading.trailing.equalToSuperview()
            $0.height.equalTo(60)
        }

        profileView.snp.makeConstraints {
            $0.top.equalTo(archiveHeaderView.snp.bottom)
            $0.leading.trailing.equalToSuperview().inset(16)
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
            $0.width.equalTo(343)
            $0.height.equalTo(127)
        }

        calendarView.snp.makeConstraints {
            $0.top.equalTo(mountainMapView.snp.bottom).offset(32)
            $0.horizontalEdges.equalToSuperview().inset(16)
            $0.height.equalTo(337)
        }
    }

    private func loadDummyData() {
        profileView.configure(with: ArchiveHomeDummyData.profile)
        monthSelector.configure(
            title: ArchiveHomeDummyData.monthTitle(year: year, month: month),
            canMoveToPreviousMonth: ArchiveHomeDummyData.canMoveToPreviousMonth(year: year, month: month),
            canMoveToNextMonth: ArchiveHomeDummyData.canMoveToNextMonth(year: year, month: month)
        )
        mountainMapView.configure(levels: ArchiveHomeDummyData.mountainLevels(year: year, month: month))
        calendarView.configure(days: ArchiveHomeDummyData.calendarDays(year: year, month: month))
    }

    override func setAddTarget() {
        monthSelector.onPreviousTap = { [weak self] in
            self?.moveToPreviousMonth()
        }

        monthSelector.onNextTap = { [weak self] in
            self?.moveToNextMonth()
        }

        calendarView.onSelectDay = { [weak self] day in
            self?.route(to: day)
        }
    }

    private func moveToPreviousMonth() {
        guard ArchiveHomeDummyData.canMoveToPreviousMonth(year: year, month: month) else { return }

        if month == 1 {
            year -= 1
            month = 12
        } else {
            month -= 1
        }

        loadDummyData()
    }

    private func moveToNextMonth() {
        guard ArchiveHomeDummyData.canMoveToNextMonth(year: year, month: month) else { return }

        if month == 12 {
            year += 1
            month = 1
        } else {
            month += 1
        }

        loadDummyData()
    }

    private func route(to day: CalendarModel) {
        switch day.recordState {
        case .none:
            return

        case .background:
            navigationController?.pushViewController(SampleViewController(), animated: true)

        case .badge:
            let listViewController = ArchiveListViewController()
            listViewController.modalPresentationStyle = .pageSheet
            present(listViewController, animated: true)
        }
    }
}
