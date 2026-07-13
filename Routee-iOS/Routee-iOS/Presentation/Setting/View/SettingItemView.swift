//
//  SettingItemView.swift
//  Routee-iOS
//
//  Created by 김세령 on 7/13/26.
//

import UIKit

import SnapKit
import Then

final class SettingItemView: UIControl {
    
    // MARK: - UI Properties
    
    private let titleLabel = UILabel()
    private let chevronImageView = UIImageView()
    
    // MARK: - Initializer
    
    init(title: String) {
        super.init(frame: .zero)
        
        titleLabel.text = title
        setStyle()
        setUI()
        setLayout()
    }
    
    required init?(coder: NSCoder) {
        fatalError()
    }
    
    // MARK: - UI Setting
    
    private func setStyle() {
        titleLabel.do {
            $0.textColor = .staticWhite
            $0.font = .label_m_14
        }
        
        chevronImageView.do {
            $0.image = UIImage(named: "ic_chevron_right_sm_white")
            $0.contentMode = .scaleAspectFit
        }
    }
    
    private func setUI() {
        addSubviews(titleLabel, chevronImageView)
    }
    
    private func setLayout() {
        titleLabel.snp.makeConstraints {
            $0.leading.centerY.equalToSuperview()
            $0.verticalEdges.equalToSuperview()
        }
        
        chevronImageView.snp.makeConstraints {
            $0.trailing.centerY.equalToSuperview()
            $0.size.equalTo(24)
        }
    }
}
