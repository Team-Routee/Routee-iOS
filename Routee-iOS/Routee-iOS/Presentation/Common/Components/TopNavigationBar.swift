//
//  TopNavigationBar.swift
//  Routee-iOS
//
//  Created by 김세령 on 7/9/26.
//

import UIKit

import SnapKit
import Then

final class TopNavigationBar: BaseUIView {
    
    // MARK: - Properties
    
    var backButtonAction: (() -> Void)?
    var rightButtonAction: (() -> Void)?
    private let rightTitle: String
    
    // MARK: - UI Properties
    
    private let backButton = UIButton()
    private let rightButton = UIButton()
    
    // MARK: - Initializer
    
    init(rightTitle: String) {
        self.rightTitle = rightTitle
        super.init(frame: .zero)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - UI Setting
    
    override func setStyle() {
        backButton.do {
            $0.setImage(UIImage(named: "ic_arrow_left_sm_white"), for: .normal)
            $0.addTarget(self, action: #selector(didTapBackButton), for: .touchUpInside)
        }
        
        rightButton.do {
            $0.setTitle(rightTitle, for: .normal)
            $0.setTitleColor(.staticWhite, for: .normal)
            $0.titleLabel?.font = .label_sb_18
            $0.addTarget(self, action: #selector(didTapRightButton), for: .touchUpInside)
        }
    }
    
    override func setUI() {
        addSubviews(backButton, rightButton)
    }
    
    override func setLayout() {
        snp.makeConstraints {
            $0.height.equalTo(44)
        }
        
        backButton.snp.makeConstraints {
            $0.leading.equalToSuperview().inset(4)
            $0.centerY.equalToSuperview()
            $0.size.equalTo(44)
        }
        
        rightButton.snp.makeConstraints {
            $0.trailing.equalToSuperview().inset(4)
            $0.centerY.equalToSuperview()
            $0.height.equalTo(42)
            $0.width.equalTo(63)
        }
    }
    
    // MARK: - Actions

    @objc
    private func didTapBackButton() {
        backButtonAction?()
    }
    
    @objc
    private func didTapRightButton() {
        rightButtonAction?()
    }
}
