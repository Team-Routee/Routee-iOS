//
//  TimeLineViewController.swift
//  Routee-iOS
//
//  Created by 초긍정행운의포춘쿠키 on 7/12/26.
//

import UIKit

final class TimeLineViewController: BaseUIViewController {

    // MARK: - Properties

    var titleDidUpdate: ((Int64, String) -> Void)?

    // MARK: - UI Properties

    private let rootView: TimeLineView

    // MARK: - Private Properties

    private let record: ActivityListModel?
    private let viewModel = TimeLineViewModel()
    private var activityStatisticsTask: Task<Void, Never>?
    private var activityRouteTask: Task<Void, Never>?
    private var timeLineListTask: Task<Void, Never>?
    private var courseListTask: Task<Void, Never>?
    private var titleUpdateTask: Task<Void, Never>?

    // MARK: - Initializer

    init(record: ActivityListModel? = nil) {
        self.record = record
        self.rootView = TimeLineView(record: record)
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Life Cycle

    override func loadView() {
        view = rootView
    }

    // MARK: - UI Setting

    override func setView() {
        rootView.backButtonAction = { [weak self] in
            self?.dismiss(animated: true)
        }

        rootView.titleEditingDidEnd = { [weak self] title in
            self?.updateArchiveActivityTitle(title: title)
        }

        loadActivityStatistics()
        loadActivityRoute()
        loadTimeLineList()
        loadCourseList()
    }

    // MARK: - Private Methods

    private func loadActivityStatistics() {
        guard let activityId = record?.activityId else { return }

        activityStatisticsTask?.cancel()
        activityStatisticsTask = Task { [weak self] in
            guard let self else { return }

            do {
                let metric = try await viewModel.fetchActivityStatistics(activityId: activityId)

                guard !Task.isCancelled else { return }

                await MainActor.run {
                    self.rootView.configureMetric(with: metric)
                }
            } catch {
                guard !Task.isCancelled else { return }

                RouteeLogger.error(error)
            }
        }
    }

    private func loadActivityRoute() {
        guard let activityId = record?.activityId else { return }

        activityRouteTask?.cancel()
        activityRouteTask = Task { [weak self] in
            guard let self else { return }

            do {
                let model = try await viewModel.fetchActivityRoute(activityId: activityId)

                guard !Task.isCancelled else { return }

                await MainActor.run {
                    self.rootView.configureTrackMap(with: model)
                }
            } catch {
                guard !Task.isCancelled else { return }

                RouteeLogger.error(error)
            }
        }
    }

    private func loadTimeLineList() {
        guard let activityId = record?.activityId else { return }

        timeLineListTask?.cancel()
        timeLineListTask = Task { [weak self] in
            guard let self else { return }

            do {
                let model = try await viewModel.fetchTimeLineList(activityId: activityId)

                guard !Task.isCancelled else { return }

                await MainActor.run {
                    self.rootView.configureTimeLineList(with: model)
                }
            } catch {
                guard !Task.isCancelled else { return }

                RouteeLogger.error(error)
            }
        }
    }

    private func loadCourseList() {
        guard let activityId = record?.activityId else { return }

        courseListTask?.cancel()
        courseListTask = Task { [weak self] in
            guard let self else { return }

            do {
                let model = try await viewModel.fetchCourseList(activityId: activityId)

                guard !Task.isCancelled else { return }

                await MainActor.run {
                    self.rootView.configureCourseList(with: model)
                }
            } catch {
                guard !Task.isCancelled else { return }

                RouteeLogger.error(error)
            }
        }
    }

    private func updateArchiveActivityTitle(title: String) {
        guard let activityId = record?.activityId else { return }

        titleUpdateTask?.cancel()
        titleUpdateTask = Task { [weak self] in
            guard let self else { return }

            do {
                let response = try await viewModel.updateArchiveActivityTitle(
                    activityId: activityId,
                    title: title
                )

                await MainActor.run {
                    self.titleDidUpdate?(response.activityId, response.title)
                }
            } catch {
                guard !Task.isCancelled else { return }

                RouteeLogger.error(error)
            }
        }
    }
}
