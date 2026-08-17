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
    private let title: String?
    private let rightTitle: String?
    
    // MARK: - UI Properties
    
    private let backButton = UIButton()
    private let titleLabel = UILabel()
    private let rightButton = UIButton()
    
    // MARK: - Initializer
    
    init(title: String? = nil, rightTitle: String? = nil) {
        self.title = title
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
        }

        titleLabel.do {
            $0.text = title
            $0.textColor = .staticWhite
            $0.font = .label_sb_18
            $0.textAlignment = .center
            $0.isHidden = title == nil
        }
        
        rightButton.do {
            $0.setTitle(rightTitle, for: .normal)
            $0.setTitleColor(.staticWhite, for: .normal)
            $0.titleLabel?.font = .label_sb_18
            $0.isHidden = rightTitle == nil
            $0.isUserInteractionEnabled = rightTitle != nil
        }
    }
    
    override func setUI() {
        addSubviews(backButton, titleLabel, rightButton)
        
        setActions()
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

        titleLabel.snp.makeConstraints {
            $0.center.equalToSuperview()
        }
        
        rightButton.snp.makeConstraints {
            $0.trailing.equalToSuperview().inset(4)
            $0.centerY.equalToSuperview()
            $0.height.equalTo(42)
            $0.width.equalTo(63)
        }
    }
    
    // MARK: - Public Methods

    func setBackButtonEnabled(_ isEnabled: Bool) {
        backButton.isEnabled = isEnabled
    }

    // MARK: - Private Methods

    private func setActions() {
        backButton.addTarget(self, action: #selector(didTapBackButton), for: .touchUpInside)
        rightButton.addTarget(self, action: #selector(didTapRightButton), for: .touchUpInside)
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
