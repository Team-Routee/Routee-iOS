//
//  ContactView.swift
//  Routee-iOS
//
//  Created by 초긍정행운의포춘쿠키 on 8/26/26.
//

import UIKit

import SnapKit
import Then

final class ContactView: BaseUIView {
    
    // MARK: - Properties
    
    var backButtonAction: (() -> Void)?
    var kakaoButtonAction: (() -> Void)?
    var emailButtonAction: (() -> Void)?
    
    // MARK: - UI Properties
    
    private let backgroundGradientView = RouteeEllipseBackground()
    private let topNavigationBar = TopNavigationBar(title: "1:1 문의하기")
    private let titleLabel = UILabel()
    private let descriptionLabel = UILabel()
    private let kakaoButton = UIButton()
    private let emailButton = UIButton()
    
    // MARK: - UI Setting
    
    override func setStyle() {
        backgroundColor = .bgPrimary
        
        titleLabel.do {
            $0.text = "도움이 필요하신가요?"
            $0.textColor = .staticWhite
            $0.font = .title_sb_20
        }
        descriptionLabel.do {
            $0.text = """
                원하시는 기능 혹은 오류가 발생한다면 언제든지 문의주세요.
                순차적으로 빠르게 답변드리겠습니다
                """
            $0.textColor = .grey200
            $0.font = .label_r_12
        }

        kakaoButton.do {
            $0.setImage(.ctaKakao, for: .normal)
        }

        emailButton.do {
            $0.setImage(.ctaEmail, for: .normal)
        }
    }
    
    override func setUI() {
        addSubviews(
            backgroundGradientView,
            topNavigationBar,
            titleLabel,
            descriptionLabel,
            kakaoButton,
            emailButton
        )

        setAddTarget()
    }
    
    override func setLayout() {
        backgroundGradientView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }

        topNavigationBar.snp.makeConstraints {
            $0.top.equalTo(safeAreaLayoutGuide).offset(10)
            $0.horizontalEdges.equalToSuperview()
        }

        titleLabel.snp.makeConstraints {
            $0.top.equalTo(topNavigationBar.snp.bottom).offset(27)
            $0.leading.equalToSuperview().inset(32)
        }

        descriptionLabel.snp.makeConstraints {
            $0.top.equalTo(titleLabel.snp.bottom).offset(8)
            $0.leading.equalTo(titleLabel)
        }

        kakaoButton.snp.makeConstraints {
            $0.top.equalTo(descriptionLabel.snp.bottom).offset(32)
            $0.centerX.equalToSuperview()
            $0.width.equalTo(343)
            $0.height.equalTo(48)
        }

        emailButton.snp.makeConstraints {
            $0.top.equalTo(kakaoButton.snp.bottom).offset(12)
            $0.centerX.equalToSuperview()
            $0.width.equalTo(343)
            $0.height.equalTo(48)
        }
    }

    // MARK: - Private Methods

    private func setAddTarget() {
        topNavigationBar.backButtonAction = { [weak self] in
            self?.backButtonAction?()
        }

        kakaoButton.addTarget(self, action: #selector(didTapKakaoButton), for: .touchUpInside)
        emailButton.addTarget(self, action: #selector(didTapEmailButton), for: .touchUpInside)
    }

    // MARK: - Actions

    @objc
    private func didTapKakaoButton() {
        kakaoButtonAction?()
    }

    @objc
    private func didTapEmailButton() {
        emailButtonAction?()
    }
}
