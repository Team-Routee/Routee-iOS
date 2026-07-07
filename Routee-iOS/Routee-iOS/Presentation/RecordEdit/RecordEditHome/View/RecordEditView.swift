//
//  RecordEditView.swift
//  Routee-iOS
//
//  Created by 김세령 on 7/6/26.
//

import UIKit

import SnapKit
import Then

final class RecordEditView: BaseUIView {
    
    // MARK: - UI Properties
    
    private let titleLabel = UILabel()
    private let monthSelector = MonthSelector()
    
    private let flowLayout = UICollectionViewFlowLayout()
    private(set) lazy var workoutRecordCollectionView = UICollectionView(
        frame: .zero,
        collectionViewLayout: flowLayout
    )
    
    // MARK: - UI Settings
    
    override func setStyle() {
        backgroundColor = .bgPrimary
        
        titleLabel.do {
            $0.text = "운동 기록 편집"
            $0.font = .title_sb_20
            $0.textColor = .staticWhite
        }
        
        flowLayout.do {
            $0.scrollDirection = .vertical
            $0.itemSize = CGSize(width: 152, height: 243)
            $0.minimumInteritemSpacing = 23
            $0.minimumLineSpacing = 20
            $0.sectionInset = .zero
        }
        
        workoutRecordCollectionView.do {
            $0.backgroundColor = .clear
            $0.showsVerticalScrollIndicator = false
            $0.contentInsetAdjustmentBehavior = .never
            $0.contentInset.bottom = TabBarViewController.customTabBarHeight + 20
        }
    }
    
    override func setUI() {
        addSubviews(titleLabel, monthSelector, workoutRecordCollectionView)
    }
    
    override func setLayout() {
        titleLabel.snp.makeConstraints {
            $0.top.equalTo(safeAreaLayoutGuide).inset(16)
            $0.leading.equalToSuperview().inset(16)
        }
        
        monthSelector.snp.makeConstraints {
            $0.top.equalTo(titleLabel.snp.bottom).offset(28)
            $0.centerX.equalToSuperview()
            $0.height.equalTo(28)
            $0.width.equalTo(160)
        }
        
        workoutRecordCollectionView.snp.makeConstraints {
            $0.top.equalTo(monthSelector.snp.bottom).offset(20)
            $0.centerX.equalToSuperview()
            $0.width.equalTo(327)
            $0.bottom.equalTo(safeAreaLayoutGuide)
        }
    }
    
    func setMonthChangedHandler(_ handler: @escaping (Date) -> Void) {
        monthSelector.onMonthChanged = handler
    }
}
