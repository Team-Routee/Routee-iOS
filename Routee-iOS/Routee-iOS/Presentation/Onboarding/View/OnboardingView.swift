//
//  OnboardingView.swift
//  Routee-iOS
//
//  Created by LEESANGYUP on 7/6/26.
//

import UIKit

import SnapKit
import Then

final class OnboardingView: BaseUIView {
    
    // MARK: - UI Properties
    
    private let backgroundImageView = RouteeEllipseBackground()
    private let settingGuideLabel = UILabel()
    private let nicknameTextField = RouteeTextField()
    let startButton = RouteeButton(titleText: "시작하기", type: .disabled)
    
    var nickname: String {
        nicknameTextField.text ?? ""
    }
    
    override init(frame: CGRect) {
        super.init(frame: .zero)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - UI Setting
    
    override func setUI() {
        addSubviews(
            backgroundImageView,
            settingGuideLabel,
            nicknameTextField,
            startButton
        )

        nicknameTextField.addTarget(
            self,
            action: #selector(nicknameDidChange),
            for: .editingChanged
        )
    }
    
    override func setStyle() {
        settingGuideLabel.do {
            $0.text = "사용할 닉네임을 설정해주세요."
            $0.font = .title_sb_20
            $0.textColor = .static_white
        }
    }
    
    override func setLayout() {
        backgroundImageView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
        
        settingGuideLabel.snp.makeConstraints {
            $0.top.equalTo(safeAreaLayoutGuide).inset(156)
            $0.centerX.equalToSuperview()
        }
        
        nicknameTextField.snp.makeConstraints {
            $0.top.equalTo(settingGuideLabel.snp.bottom).offset(86)
            $0.horizontalEdges.equalToSuperview().inset(CGFloat.s32)
        }
        
        startButton.snp.makeConstraints {
            $0.bottom.equalTo(safeAreaLayoutGuide).inset(59)
            $0.horizontalEdges.equalToSuperview().inset(16)
        }
    }

    @objc
    private func nicknameDidChange() {
        let nickname = nicknameTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
        startButton.updateType(nickname.isEmpty ? .disabled : .enabled)
    }
}
