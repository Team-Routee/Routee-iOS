//
// ArchiveViewController.swift
//  Routee-iOS
//
//  Created by 초긍정행운의포춘쿠키 on 7/7/26.
//

import UIKit

final class ArchiveHomeViewController: BaseUIViewController {

    // MARK: - Properties

    private var year = Calendar.current.component(.year, from: Date())
    private var month = Calendar.current.component(.month, from: Date())
    private let rootView = ArchiveHomeView()

    // MARK: - Life Cycle

    override func viewDidLoad() {
        super.viewDidLoad()

        loadDummyData()
    }

    override func setView() {
        view = rootView
    }

    private func loadDummyData() {
        rootView.configureProfile(with: ArchiveHomeDummyData.profile)
        rootView.configureMonthSelector(
            title: ArchiveHomeDummyData.monthTitle(year: year, month: month),
            canMoveToPreviousMonth: ArchiveHomeDummyData.canMoveToPreviousMonth(year: year, month: month),
            canMoveToNextMonth: ArchiveHomeDummyData.canMoveToNextMonth(year: year, month: month)
        )
        rootView.configureMountainMap(levels: ArchiveHomeDummyData.mountainLevels(year: year, month: month))
        rootView.configureCalendar(days: ArchiveHomeDummyData.calendarDays(year: year, month: month))
    }

    override func setAddTarget() {
        rootView.onPreviousMonthTap = { [weak self] in
            self?.moveToPreviousMonth()
        }

        rootView.onNextMonthTap = { [weak self] in
            self?.moveToNextMonth()
        }

        rootView.onSelectDay = { [weak self] day in
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

        case .background, .badge:
            navigationController?.pushViewController(SampleViewController(), animated: true)
        }
    }
}
