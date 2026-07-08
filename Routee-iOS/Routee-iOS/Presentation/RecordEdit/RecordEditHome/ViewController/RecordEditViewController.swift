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
    private let rootView = RecordEditView()
    private let allRecords = WorkoutDummyData.dummyWorkoutRecords
    private var records: [WorkoutRecordModel] = []
    
    // MARK: - Life Cycle
    
    override func loadView() {
        view = rootView
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setCollectionView()
        setMonthSelector()
        updateRecords(for: Date())
    }
    
    // MARK: - Private Methods
    
    private func setMonthSelector() {
        rootView.setMonthChangedHandler { [weak self] date in
            self?.updateRecords(for: date)
        }
    }
    
    private func updateRecords(for month: Date) {
        records = allRecords.filter { $0.date.isSameMonth(as: month) }
        rootView.updateView(isEmpty: records.isEmpty)
        rootView.workoutRecordCollectionView.reloadData()
        rootView.scrollToTop()
    }
}

    // MARK: - extension

extension RecordEditViewController: UICollectionViewDelegate {
    private func setCollectionView() {
        rootView.workoutRecordCollectionView.register(
            WorkoutRecordCell.self,
            forCellWithReuseIdentifier: WorkoutRecordCell.identifier
        )
        
        rootView.workoutRecordCollectionView.dataSource = self
        rootView.workoutRecordCollectionView.delegate = self
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
        
        cell.configure(with: records[indexPath.item])
        
        return cell
    }
}
