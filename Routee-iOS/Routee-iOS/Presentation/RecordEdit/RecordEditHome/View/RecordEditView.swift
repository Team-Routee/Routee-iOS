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
    
    // MARK: - Metric
    
    private enum Metric {
        static let bottomSpacingAboveTabBar: CGFloat = 20
    }
    
    // MARK: - UI Properties
    
    private let titleLabel = UILabel()
    private let monthSelector = MonthSelector()
    
    private let emptyDataStackView = UIStackView()
    private let emptyDataImageView = UIImageView()
    private let emptyDataLabel = UILabel()
    
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
        
        emptyDataStackView.do {
            $0.isHidden = true
            $0.axis = .vertical
            $0.spacing = 24
            $0.alignment = .center
        }
        
        emptyDataImageView.do {
            $0.image = UIImage(named: "graphic_empty_data_xl")
        }
        
        emptyDataLabel.do {
            $0.text = "기록이 없어요."
            $0.font = .label_m_16
            $0.textColor = .grey300
            $0.numberOfLines = 0
        }
        
        workoutRecordCollectionView.do {
            $0.backgroundColor = .clear
            $0.showsVerticalScrollIndicator = false
            $0.contentInsetAdjustmentBehavior = .never
        }
    }
    
    override func setUI() {
        addSubviews(titleLabel, monthSelector, workoutRecordCollectionView, emptyDataStackView)
        
        emptyDataStackView.addArrangedSubviews(emptyDataImageView, emptyDataLabel)
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
        
        emptyDataStackView.snp.makeConstraints {
            $0.centerX.centerY.equalToSuperview()
        }
        
        emptyDataImageView.snp.makeConstraints {
            $0.height.equalTo(72)
            $0.width.equalTo(84)
        }
        
        workoutRecordCollectionView.snp.makeConstraints {
            $0.top.equalTo(monthSelector.snp.bottom).offset(20)
            $0.centerX.equalToSuperview()
            $0.width.equalTo(327)
            $0.bottom.equalToSuperview()
        }
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        let bottomInset = safeAreaInsets.bottom
        + TabBarViewController.customTabBarHeight
        + Metric.bottomSpacingAboveTabBar
        
        workoutRecordCollectionView.contentInset.bottom = bottomInset
        workoutRecordCollectionView.verticalScrollIndicatorInsets.bottom = bottomInset
    }
    
    // MARK: - Private Methods
    
    func updateView(isEmpty: Bool) {
        workoutRecordCollectionView.isHidden = isEmpty
        emptyDataStackView.isHidden = !isEmpty
    }
    
    // MARK: - Public Methods

    func setMonthChangedHandler(_ handler: @escaping (Date) -> Void) {
        monthSelector.onMonthChanged = handler
    }
}
