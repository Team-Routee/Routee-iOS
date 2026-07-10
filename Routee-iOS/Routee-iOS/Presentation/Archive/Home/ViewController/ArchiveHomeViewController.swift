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
            title: monthTitle(year: year, month: month),
            canMoveToPreviousMonth: canMoveToPreviousMonth(year: year, month: month),
            canMoveToNextMonth: canMoveToNextMonth(year: year, month: month)
        )
        rootView.configureMountainMap(durationMinutes: ArchiveHomeDummyData.dummyMountainDurationMinutes)
        rootView.configureCalendar(
            days: ArchiveCalendar.makeDays(
                year: year,
                month: month,
                records: ArchiveHomeDummyData
                    .dummyCalendarRecordsByMonth[monthKey(year: year, month: month)] ?? []
            )
        )
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
        guard canMoveToPreviousMonth(year: year, month: month) else { return }

        if month == 1 {
            year -= 1
            month = 12
        } else {
            month -= 1
        }

        loadDummyData()
    }

    private func moveToNextMonth() {
        guard canMoveToNextMonth(year: year, month: month) else { return }

        if month == 12 {
            year += 1
            month = 1
        } else {
            month += 1
        }

        loadDummyData()
    }

    private func route(to day: DayCellModel) {
        switch day.recordState {
        case .none:
            return

        case .background, .badge:
            navigationController?.pushViewController(SampleViewController(), animated: true)
        }
    }

    private func monthTitle(year: Int, month: Int) -> String {
        "\(year)년 \(month)월"
    }

    private func monthKey(year: Int, month: Int) -> String {
        String(format: "%04d-%02d", year, month)
    }

    private func canMoveToPreviousMonth(year: Int, month: Int) -> Bool {
        monthStart(year: year, month: month) > monthStart(from: ArchiveHomeDummyData.profile.joinedDate)
    }

    private func canMoveToNextMonth(year: Int, month: Int) -> Bool {
        monthStart(year: year, month: month) < monthStart(from: Date())
    }

    private func monthStart(from joinedDate: String) -> Date {
        let formatter = DateFormatter()
        formatter.calendar = Foundation.Calendar(identifier: .gregorian)
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.dateFormat = "yyyy-MM-dd"

        let date = formatter.date(from: joinedDate) ?? Date()
        return monthStart(from: date)
    }

    private func monthStart(from date: Date) -> Date {
        let components = Foundation.Calendar.current.dateComponents([.year, .month], from: date)
        return Foundation.Calendar.current.date(from: components) ?? date
    }

    private func monthStart(year: Int, month: Int) -> Date {
        var components = DateComponents()
        components.year = year
        components.month = month
        components.day = 1

        return Foundation.Calendar.current.date(from: components) ?? Date()
    }
}
