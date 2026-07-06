//
//  MonthSelector.swift
//  Routee-iOS
//
//  Created by 김세령 on 7/6/26.
//

import UIKit

import SnapKit
import Then

final class MonthSelector: BaseUIView {
    
    // MARK: - UI Properties
    
    private let stackView = UIStackView()
    private let leftButton = UIButton()
    private let monthLabel = UILabel()
    private let rightButton = UIButton()
    
    // MARK: - UI Settings
    
    override func setStyle() {
        stackView.do {
            $0.axis = .horizontal
            $0.spacing = 8
        }
        
        leftButton.do {
            $0.setImage(UIImage(named: "ic_chevron_left_sm_white"), for: .normal)
        }
        
        monthLabel.do {
            $0.text = "2026년 3월"
            $0.textColor = .staticWhite
            $0.font = .title_sb_18
        }
        
        rightButton.do {
            $0.setImage(UIImage(named: "ic_chevron_right_sm_white"), for: .normal)
        }
    }
    
    override func setUI() {
        stackView.addArrangedSubviews(
            leftButton, monthLabel, rightButton
        )
    }
    
    override func setLayout() {
        stackView.snp.makeConstraints {
            $0.centerX.equalToSuperview()
            $0.centerY.equalToSuperview()
        }
        
        leftButton.snp.makeConstraints {
            $0.size.equalTo(28)
        }

        rightButton.snp.makeConstraints {
            $0.size.equalTo(28)
        }
    }
}
