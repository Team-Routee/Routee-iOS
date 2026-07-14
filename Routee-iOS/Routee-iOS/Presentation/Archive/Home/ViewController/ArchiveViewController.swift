//
// ArchiveViewController.swift
//  Routee-iOS
//
//  Created by 초긍정행운의포춘쿠키 on 7/7/26.
//

import UIKit

final class ArchiveViewController: BaseUIViewController {

    // MARK: - Properties

    private var year = Calendar.current.component(.year, from: Date())
    private var month = Calendar.current.component(.month, from: Date())
    private let rootView = ArchiveView()
    private let viewModel = ArchiveHomeViewModel()
    private var dimView: UIView?
    private var archiveTask: Task<Void, Never>?

    // MARK: - Life Cycle

    override func viewDidLoad() {
        super.viewDidLoad()

        rootView.configureProfile(with: ArchiveHomeDummyData.profile)
        loadArchive()
    }

    override func setView() {
        view = rootView
    }

    private func loadArchive() {
        let requestedYear = year
        let requestedMonth = month

        rootView.configureMonthSelector(
            title: monthTitle(year: requestedYear, month: requestedMonth),
            canMoveToPreviousMonth: canMoveToPreviousMonth(year: requestedYear, month: requestedMonth),
            canMoveToNextMonth: canMoveToNextMonth(year: requestedYear, month: requestedMonth)
        )

        archiveTask?.cancel()
        archiveTask = Task { [weak self] in
            guard let self else { return }

            do {
                let records = try await viewModel.fetchArchive(
                    year: requestedYear,
                    month: requestedMonth
                )

                guard
                    !Task.isCancelled,
                    year == requestedYear,
                    month == requestedMonth
                else { return }

                applyArchive(
                    records,
                    year: requestedYear,
                    month: requestedMonth
                )
            } catch {
                guard
                    !Task.isCancelled,
                    year == requestedYear,
                    month == requestedMonth
                else { return }

                RouteeLogger.error(error)
                applyArchive(
                    [],
                    year: requestedYear,
                    month: requestedMonth
                )
            }
        }
    }

    private func applyArchive(
        _ records: [ArchiveModel],
        year: Int,
        month: Int
    ) {
        let durationMinutes = viewModel.makeDurationMinutes(
            year: year,
            month: month,
            records: records
        )
        rootView.configureMountainMap(
            levels: viewModel.makeMountainMapLevels(from: durationMinutes)
        )
        rootView.configureCalendar(
            days: viewModel.makeCalendarDays(
                year: year,
                month: month,
                records: records
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

        loadArchive()
    }

    private func moveToNextMonth() {
        guard canMoveToNextMonth(year: year, month: month) else { return }

        if month == 12 {
            year += 1
            month = 1
        } else {
            month += 1
        }

        loadArchive()
    }

    private func route(to day: CalendarCellModel) {
        switch day.recordState {
        case .none:
            return

        case .single, .multiple:
            guard let dateText = listDateText(from: day.activityDate) else { return }

            let listViewController = DailyRecordBottomSheetViewController(
                model: listModel(dateText: dateText)
            )
            listViewController.modalPresentationStyle = .pageSheet
            listViewController.presentationController?.delegate = self
            showDimView()
            present(listViewController, animated: true)
        }
    }

    private func showDimView() {
        guard let containerView = tabBarController?.view ?? view.window,
              dimView == nil else { return }

        let dimView = UIView(frame: containerView.bounds)
        dimView.backgroundColor = UIColor.black.withAlphaComponent(0.7)
        dimView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        dimView.alpha = 0
        containerView.addSubview(dimView)

        UIView.animate(withDuration: 0.2) {
            dimView.alpha = 1
        }

        self.dimView = dimView
    }

    private func hideDimView(animated: Bool = true) {
        guard let dimView else { return }

        guard animated else {
            dimView.removeFromSuperview()
            self.dimView = nil
            return
        }

        UIView.animate(withDuration: 0.2) {
            dimView.alpha = 0
        } completion: { _ in
            dimView.removeFromSuperview()
        }

        self.dimView = nil
    }

    private func listDateText(from activityDate: String?) -> String? {
        guard let activityDate else { return nil }

        return activityDate.replacingOccurrences(of: "-", with: ".")
    }

    private func listModel(dateText: String) -> CalendarDateModel {
        DailyDummyData.dummyModelsByDate[dateText] ?? .init(dateText: dateText, items: [])
    }

    private func monthTitle(year: Int, month: Int) -> String {
        "\(year)년 \(month)월"
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

    // MARK: - Extension

extension ArchiveViewController: UIAdaptivePresentationControllerDelegate {

    func presentationControllerDidDismiss(_ presentationController: UIPresentationController) {
        hideDimView()
    }

    func presentationControllerWillDismiss(_ presentationController: UIPresentationController) {
        hideDimView()
    }
}
