//
//  RecordEditViewController.swift
//  Routee-iOS
//
//  Created by 김세령 on 7/6/26.
//

import UIKit

import SnapKit
import Then

final class RecordEditViewController: BaseUIViewController {

    // MARK: - Properties

    var onMonthChanged: ((Date) -> Void)?
    private let viewModel = RecordEditViewModel()
    private let editorViewModel = EditorViewModel()
    private let summaryViewModel = MemberSummaryViewModel()
    private var records: [WorkoutListModel] = []
    private var selectedMonth = Date().startOfMonth
    private var titleUpdateTask: Task<Void, Never>?
    private var recordTapTask: Task<Void, Never>?
    private let joinedDateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.calendar = Calendar(identifier: .gregorian)
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.dateFormat = "yyyy-MM-dd"
        return formatter
    }()

    // MARK: - UI Properties

    private let rootView = RecordEditView()

    // MARK: - Life Cycle

    override func loadView() {
        view = rootView
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        setCollectionView()
        setMonthSelector()
    }

    deinit {
        recordTapTask?.cancel()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        loadSummary()
        fetchRecords(for: selectedMonth)
    }

    // MARK: - Private Methods

    private func setCollectionView() {
        rootView.workoutRecordCollectionView.register(
            WorkoutRecordCell.self,
            forCellWithReuseIdentifier: WorkoutRecordCell.identifier
        )

        rootView.workoutRecordCollectionView.dataSource = self
    }

    private func setMonthSelector() {
        rootView.setMonthChangedHandler { [weak self] date in
            self?.selectedMonth = date
            self?.fetchRecords(for: date, showErrorToast: true)
        }
    }

    private func loadSummary() {
        Task { [weak self] in
            guard let self else { return }

            do {
                try await LoadingOverlayManager.shared.perform {
                    let summary = try await self.summaryViewModel.fetchSummary()
                    let joinDateText = String(summary.joinDate.prefix(10))
                    let joinDate = self.joinedDateFormatter.date(from: joinDateText)

                    self.rootView.configureMinimumMonth(joinDate)
                }
            } catch {
                RouteeLogger.error(error)
            }
        }
    }

    private func fetchRecords(
        for month: Date,
        showErrorToast: Bool = false
    ) {
        Task { [weak self] in
            guard let self else { return }

            do {
                let components = Calendar.current.dateComponents([.year, .month], from: month)
                guard let year = components.year,
                      let month = components.month else { return }

                try await LoadingOverlayManager.shared.perform {
                    try await self.viewModel.fetchWorkoutList(
                        year: year,
                        month: month
                    )

                    let fetchedRecords = self.viewModel.records
                    self.records = fetchedRecords
                    self.rootView.updateView(isEmpty: fetchedRecords.isEmpty)
                    self.rootView.workoutRecordCollectionView.reloadData()
                    self.rootView.scrollToTop()
                }
            } catch {
                RouteeLogger.error(error)
                await MainActor.run {
                    self.records.removeAll()
                    self.rootView.updateView(isEmpty: true)
                    self.rootView.workoutRecordCollectionView.reloadData()
                    self.rootView.scrollToTop()
                    if showErrorToast {
                        self.rootView.showToast(title: ToastMessage.checkNetworkConnection)
                    }
                }
            }
        }
    }

    private func pushEditorViewController(activityId: Int64) {
        let editorViewController = EditorViewController(
            activityId: activityId,
            entryPoint: .recordEditTab
        )
        navigationController?.pushViewController(editorViewController, animated: false)
    }

    private func handleRecordTap(activityId: Int64) {
        recordTapTask?.cancel()
        recordTapTask = Task { [weak self] in
            guard let self else { return }

            do {
                try await editorViewModel.fetchActivityEditorData(activityId: activityId)

                guard !Task.isCancelled else { return }

                await MainActor.run {
                    self.pushEditorViewController(activityId: activityId)
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

    private func updateWorkoutTitle(
        activityId: Int64,
        title: String
    ) {
        titleUpdateTask?.cancel()
        titleUpdateTask = Task { [weak self] in
            guard let self else { return }

            do {
                let response = try await viewModel.updateWorkoutTitle(
                    activityId: activityId,
                    title: title
                )

                guard !Task.isCancelled else { return }

                await MainActor.run {
                    self.updateRecordTitle(
                        activityId: response.activityId,
                        title: response.title
                    )
                }
            } catch {
                guard !Task.isCancelled else { return }

                RouteeLogger.error(error)
            }
        }
    }

    private func updateRecordTitle(
        activityId: Int64,
        title: String
    ) {
        guard let index = records.firstIndex(where: { $0.activityId == activityId }) else { return }

        let record = records[index]
        records[index] = WorkoutListModel(
            activityId: record.activityId,
            title: title,
            activityDate: record.activityDate,
            timelineImageUrls: record.timelineImageUrls
        )
    }
}

extension RecordEditViewController: UICollectionViewDataSource {
    func collectionView(
        _ collectionView: UICollectionView,
        numberOfItemsInSection section: Int
    ) -> Int {
        records.count
    }

    func collectionView(
        _ collectionView: UICollectionView,
        cellForItemAt indexPath: IndexPath
    ) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(
            withReuseIdentifier: WorkoutRecordCell.identifier,
            for: indexPath
        ) as? WorkoutRecordCell else {
            return UICollectionViewCell()
        }

        let record = records[indexPath.item]

        cell.configure(with: record)
        cell.onThumbnailTap = { [weak self] in
            self?.handleRecordTap(activityId: record.activityId)
        }
        cell.onTitleEditingDidEnd = { [weak self] title in
            self?.updateWorkoutTitle(
                activityId: record.activityId,
                title: title
            )
        }

        return cell
    }
}
