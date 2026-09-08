//
//  LoginView.swift
//  Routee-iOS
//
//  Created by LEESANGYUP on 6/30/26.
//

import AuthenticationServices
import UIKit

import SnapKit
import Then

final class LoginView: BaseUIView {
    
    // MARK: - Properties

    var serviceTermsTapAction: (() -> Void)?
    var privacyPolicyTapAction: (() -> Void)?
    private var serviceAgreeLinkRange = NSRange(location: NSNotFound, length: 0)
    private var privacyPolicyLinkRange = NSRange(location: NSNotFound, length: 0)

    // MARK: - UI Properties
    
    private let backgroundImageView = UIImageView()
    lazy var signInButton = UIButton()
    private let serviceAgreeLabel = UILabel()
    private let privacyPolicyLabel = UILabel()
 
    // MARK: - UI Setting
    
    override func setUI() {
        addSubviews(
            backgroundImageView,
            signInButton,
            serviceAgreeLabel,
            privacyPolicyLabel
        )
    }
    
    override func setStyle() {
        backgroundColor = .bgPrimary
        
        backgroundImageView.do {
            $0.image = UIImage(resource: .imgBgLogin)
            $0.contentMode = .scaleAspectFit
        }
        
        signInButton.do {
            $0.setImage(UIImage(resource: .ctaAppleLoginLg), for: .normal)
        }
        
        serviceAgreeLabel.do {
            let text = "계속 진행하면 Routee의 서비스 이용약관에 동의하게 됩니다."

            serviceAgreeLinkRange = configurePolicyLabel(
                $0,
                text: text,
                linkedText: "이용약관에 동의"
            )
            $0.addGestureRecognizer(
                UITapGestureRecognizer(target: self, action: #selector(didTapServiceAgreeLabel))
            )
        }
        
        privacyPolicyLabel.do {
            let text = "개인정보 처리 방식은 개인정보 처리방침에서 확인할 수 있습니다."

            privacyPolicyLinkRange = configurePolicyLabel(
                $0,
                text: text,
                linkedText: "개인정보 처리방침"
            )
            $0.addGestureRecognizer(
                UITapGestureRecognizer(target: self, action: #selector(didTapPrivacyPolicyLabel))
            )
        }
    }
    
    override func setLayout() {
        backgroundImageView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
        
        signInButton.snp.makeConstraints {
            $0.centerX.equalToSuperview()
            $0.bottom.equalTo(serviceAgreeLabel.snp.top).offset(-24)
        }
        
        serviceAgreeLabel.snp.makeConstraints {
            $0.centerX.equalToSuperview()
            $0.bottom.equalTo(privacyPolicyLabel.snp.top).offset(-2)
        }
        
        privacyPolicyLabel.snp.makeConstraints {
            $0.centerX.equalToSuperview()
            $0.bottom.equalTo(safeAreaLayoutGuide).inset(16)
        }
    }

    // MARK: - Private Methods

    private func configurePolicyLabel(
        _ label: UILabel,
        text: String,
        linkedText: String
    ) -> NSRange {
        let font = UIFont.pretendard(.regular, size: 10)
        let attributedString = NSMutableAttributedString(
            string: text,
            attributes: [
                .font: font,
                .foregroundColor: UIColor.white60
            ]
        )
        let range = (text as NSString).range(of: linkedText)

        if range.location != NSNotFound {
            attributedString.addAttribute(
                .underlineStyle,
                value: NSUnderlineStyle.single.rawValue,
                range: range
            )
        }

        label.attributedText = attributedString
        label.textAlignment = .center
        label.isUserInteractionEnabled = true

        return range
    }

    // MARK: - Actions

    @objc
    private func didTapServiceAgreeLabel(_ gesture: UITapGestureRecognizer) {
        let point = gesture.location(in: serviceAgreeLabel)
        guard serviceAgreeLabel.containsTap(in: serviceAgreeLinkRange, at: point) else { return }

        serviceTermsTapAction?()
    }

    @objc
    private func didTapPrivacyPolicyLabel(_ gesture: UITapGestureRecognizer) {
        let point = gesture.location(in: privacyPolicyLabel)
        guard privacyPolicyLabel.containsTap(in: privacyPolicyLinkRange, at: point) else { return }

        privacyPolicyTapAction?()
    }
}
