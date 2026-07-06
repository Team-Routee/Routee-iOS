//
//  WorkoutRecordCell.swift
//  Routee-iOS
//
//  Created by 김세령 on 7/6/26.
//

import UIKit

import SnapKit
import Then

final class WorkoutRecordCell: UICollectionViewCell {
    
    // MARK: - Properties
    
    static let identifier = "WorkoutRecordCell"

    // MARK: - UI Properties
    
    private let workoutRecordThumbnail = WorkoutRecordThumbnail()
    private let titleLabel = UILabel()
    private let dateLabel = UILabel()
    
    // MARK: - init
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        setStyle()
        setUI()
        setLayout()
    }
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - UI Settings
    
    private func setStyle() {
        titleLabel.do {
            $0.text = "숭실대 동기모임 2탄"
            $0.font = .body_sb_14
            $0.textColor = .staticWhite
            $0.textAlignment = .center
        }
        
        dateLabel.do {
            $0.text = "2026.03.23"
            $0.font = .label_m_12
            $0.textColor = .staticWhite
            $0.textAlignment = .center
        }
    }
    
    private func setUI() {
        addSubviews(workoutRecordThumbnail,
                    titleLabel,
                    dateLabel
        )
    }
    
    private func setLayout() {
        workoutRecordThumbnail.snp.makeConstraints {
            $0.top.leading.trailing.equalToSuperview()
            $0.height.equalTo(192)
        }
        
        titleLabel.snp.makeConstraints {
            $0.top.equalTo(workoutRecordThumbnail.snp.bottom).offset(12)
            $0.leading.trailing.equalToSuperview()
        }
        
        dateLabel.snp.makeConstraints {
            $0.top.equalTo(titleLabel.snp.bottom).offset(2)
            $0.leading.trailing.equalToSuperview()
            $0.bottom.lessThanOrEqualToSuperview()
        }
        
    }
}
