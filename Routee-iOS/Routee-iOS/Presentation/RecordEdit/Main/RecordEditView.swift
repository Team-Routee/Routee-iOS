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
    private let monthSelectorView = MonthSelectorView()
    
    private let flowLayout = UICollectionViewFlowLayout()
    private lazy var workoutRecordCollectionView = UICollectionView(
        frame: .zero,
        collectionViewLayout: flowLayout
    )
    
    // MARK: - Private Methods
    
    override func setStyle() {
        titleLabel.do {
            $0.text = "운동 기록 편집"
            $0.font = .title_sb_20
            $0.textColor = .white
        }
        
        flowLayout.do {
            $0.scrollDirection = .vertical
            $0.minimumInteritemSpacing = 16   // 셀 사이 가로 간격
            $0.minimumLineSpacing = 32        // 셀 사이 세로 간격
            $0.sectionInset = UIEdgeInsets(
                top: 0,
                left: 24,
                bottom: 0,
                right: 24
            )
        }
    }

}
