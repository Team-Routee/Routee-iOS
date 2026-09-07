//
//  ActivityListBottomSheetViewController.swift
//  Routee-iOS
//
//  Created by 초긍정행운의포춘쿠키 on 7/7/26.
//

import UIKit

final class ActivityListBottomSheetViewController: BaseUIViewController {

    // MARK: - UI Properties
    
    private let rootView = ActivityListBottomSheet()
    private var viewModel: ActivityListViewModel
    private let timeLineViewModel = TimeLineViewModel()
    private var navigationTask: Task<Void, Never>?
    private var sheetHeight: CGFloat {
        viewModel.isCompactHeight ? 247 : 344
    }

    // MARK: - Initializer
    
    init(model: ActivityListDateModel) {
        self.viewModel = ActivityListViewModel(model: model)
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    deinit {
        navigationTask?.cancel()
    }
    
    // MARK: - Life Cycle
    
    override func loadView() {
        view = rootView
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        rootView.configure(with: viewModel)
        rootView.onRecordChevronTap = { [weak self] index in
            self?.handleActivityTap(at: index)
        }
        configureSheet()
    }

    // MARK: - Private Methods
    
    private func configureSheet() {
        view.backgroundColor = .grey900
        preferredContentSize = CGSize(width: 0, height: sheetHeight)

        guard let sheet = sheetPresentationController else { return }

        sheet.detents = [
            .custom { [weak self] _ in
                self?.sheetHeight ?? 247
            }
        ]
        sheet.prefersGrabberVisible = false
        sheet.preferredCornerRadius = 24
        sheet.prefersScrollingExpandsWhenScrolledToEdge = false
    }

    private func handleActivityTap(at index: Int) {
        guard let record = viewModel.record(at: index) else { return }

        navigationTask?.cancel()
        navigationTask = Task { [weak self] in
            guard let self else { return }

            do {
                _ = try await timeLineViewModel.fetchActivityStatistics(activityId: record.activityId)

                guard !Task.isCancelled else { return }

                await MainActor.run {
                    self.navigateToTimeLineView(record: record)
                }
            } catch {
                guard !Task.isCancelled else { return }

                RouteeLogger.error(error)
                await MainActor.run {
                    self.rootView.showToast(title: ToastMessage.checkNetworkConnection)
                }
            }
        }
    }

    private func navigateToTimeLineView(record: ActivityListModel) {
        let timeLineViewController = TimeLineViewController(record: record)
        timeLineViewController.modalPresentationStyle = .fullScreen
        timeLineViewController.titleDidUpdate = { [weak self] activityId, title in
            self?.updateActivityTitle(activityId: activityId, title: title)
        }

        present(timeLineViewController, animated: true)
    }

    private func updateActivityTitle(activityId: Int64, title: String) {
        viewModel.updateTitle(activityId: activityId, title: title)
        rootView.configure(with: viewModel)
    }
}
