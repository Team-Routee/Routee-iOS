//
//  RecordEditViewController.swift
//  Routee-iOS
//
//  Created by 김세령 on 7/6/26.
//

import UIKit

import SnapKit
import Then

final class RecordEditViewController: BaseUIViewController, UICollectionViewDelegate {
    
    private let rootView = RecordEditView()
    
    private let records = [
        "숭실대 동기모임 2탄",
        "북한산 백운대 코스",
        "아차산 야경 산책",
        "인왕산 둘레길",
        "남산 순환로 러닝",
        "한강공원 조깅",
        "청계산 등산",
        "석촌호수 산책"
    ]
    
    override func loadView() {
        view = rootView
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setCollectionView()
    }
    
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
        return records.count
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
        
        cell.configure(title: records[indexPath.item])
        
        return cell
    }
}
