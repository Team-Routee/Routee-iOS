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
    
    // MARK: - UI Properties
    
    private let backgroundImageView = UIImageView()
    private let logoImageView = UIImageView()
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
        
        logoImageView.do {
            $0.image = UIImage(resource: .routeeSignatureGradientMd)
            $0.contentMode = .scaleAspectFit
        }
        
        signInButton.do {
            $0.setImage(UIImage(resource: .ctaAppleLoginLg), for: .normal)
        }
        
        serviceAgreeLabel.do {
            let text = "계속 진행하면 Routee의 서비스 이용약관에 동의하게 됩니다."
            let font = UIFont.pretendard(.regular, size: 10)
            
            let attributedString = NSMutableAttributedString(
                string: text,
                attributes: [
                    .font: font,
                    .foregroundColor: UIColor.white60
                ]
            )
            
            let range = (text as NSString).range(of: "이용약관에 동의")

            attributedString.addAttribute(
                .underlineStyle,
                value: NSUnderlineStyle.single.rawValue,
                range: range
            )

            $0.attributedText = attributedString
            
            $0.textAlignment = .center
        }
        
        privacyPolicyLabel.do {
            let text = "개인정보 처리 방식은 개인정보 처리방침에서 확인할 수 있습니다."
            let font = UIFont.pretendard(.regular, size: 10)
            
            let attributedString = NSMutableAttributedString(
                string: text,
                attributes: [
                    .font: font,
                    .foregroundColor: UIColor.white60
                ]
            )
            
            let range = (text as NSString).range(of: "개인정보 처리방침")

            attributedString.addAttribute(
                .underlineStyle,
                value: NSUnderlineStyle.single.rawValue,
                range: range
            )

            $0.attributedText = attributedString
            
            $0.textAlignment = .center
        }
    }
    
    override func setLayout() {
        backgroundImageView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
        
        signInButton.snp.makeConstraints {
            $0.centerX.equalToSuperview()
            $0.bottom.equalTo(serviceAgreeLabel.snp.top).offset(-CGFloat.s24)
        }
        
        serviceAgreeLabel.snp.makeConstraints {
            $0.centerX.equalToSuperview()
            $0.bottom.equalTo(privacyPolicyLabel.snp.top).offset(-CGFloat.s2)
        }
        
        privacyPolicyLabel.snp.makeConstraints {
            $0.centerX.equalToSuperview()
            $0.bottom.equalTo(safeAreaLayoutGuide).inset(CGFloat.s16)
        }
    }
}
