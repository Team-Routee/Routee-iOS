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
    private var records: [WorkoutListModel] = []

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
        fetchRecords(for: Date())
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        (tabBarController as? TabBarViewController)?.setCustomTabBarHidden(false)
    }

    // MARK: - Private Methods

    private func setCollectionView() {
        rootView.workoutRecordCollectionView.register(
            WorkoutRecordCell.self,
            forCellWithReuseIdentifier: WorkoutRecordCell.identifier
        )

        rootView.workoutRecordCollectionView.dataSource = self
        rootView.workoutRecordCollectionView.delegate = self
    }

    private func setMonthSelector() {
        rootView.setMonthChangedHandler { [weak self] date in
            self?.fetchRecords(for: date)
        }
    }

    private func fetchRecords(for month: Date) {
        Task { [weak self] in
            guard let self else { return }

            do {
                let components = Calendar.current.dateComponents([.year, .month], from: month)
                guard let year = components.year,
                      let month = components.month else { return }

                try await viewModel.fetchWorkoutList(
                    year: year,
                    month: month
                )

                records = viewModel.records
                rootView.updateView(isEmpty: records.isEmpty)
                rootView.workoutRecordCollectionView.reloadData()
                rootView.scrollToTop()
            } catch {
                RouteeLogger.error(error)
            }
        }
    }

    private func pushEditorViewController(activityId: Int64) {
        let editorViewController = EditorViewController(activityId: activityId)
        navigationController?.pushViewController(editorViewController, animated: false)
    }
}

    // MARK: - extensions

extension RecordEditViewController: UICollectionViewDelegate {
    func collectionView(
        _ collectionView: UICollectionView,
        didSelectItemAt indexPath: IndexPath
    ) {
        pushEditorViewController(activityId: records[indexPath.item].activityId)
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
        cell.editButtonAction = { [weak self] in
            self?.pushEditorViewController(activityId: record.activityId)
        }

        return cell
    }
}
