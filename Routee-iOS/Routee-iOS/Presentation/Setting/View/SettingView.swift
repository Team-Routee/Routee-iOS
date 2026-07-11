//
//  SettingView.swift
//  Routee-iOS
//
//  Created by 김세령 on 7/11/26.
//

import UIKit

import SnapKit
import Then

final class SettingView: BaseUIView {
    
    // MARK: - Properties
    
    var instagramButtonAction: (() -> Void)?
    var logoutButtonAction: (() -> Void)?
    
    private enum SettingAction: Int {
        case instagram
        case logout
    }
    
    private struct SettingItem {
        let title: String
        let action: SettingAction?
    }
    
    private struct SettingSection {
        let title: String
        let items: [SettingItem]
    }
    
    private let settingSections: [SettingSection] = [
        SettingSection(
            title: "루티 이용하기",
            items: [
                SettingItem(title: "공지사항", action: nil),
                SettingItem(title: "1:1 문의하기", action: nil),
                SettingItem(title: "루티 인스타그램 바로가기", action: .instagram)
            ]
        ),
        SettingSection(
            title: "이용정책",
            items: [
                SettingItem(title: "이용약관", action: nil),
                SettingItem(title: "개인정보 처리방침", action: nil),
                SettingItem(title: "위치기반 서비스 이용약관", action: nil)
            ]
        ),
        SettingSection(
            title: "앱 정보",
            items: [
                Se00ttingItem(title: "버전정보", action: nil),
                SettingItem(title: "로그아웃", action: .logout)
            ]
        )
    ]
    
    // MARK: - UI Properties
    
    private let titleLabel = UILabel()
    private let contentStackView = UIStackView()
    
    // MARK: - UI Setting
    
    override func setStyle() {
        backgroundColor = .bgPrimary
        
        titleLabel.do {
            $0.text = "설정"
            $0.textColor = .staticWhite
            $0.font = .title_sb_20
        }
        
        contentStackView.do {
            $0.axis = .vertical
            $0.spacing = 24
        }
    }
    
    override func setUI() {
        addSubviews(titleLabel, contentStackView)
        
        settingSections.enumerated().forEach { index, section in
            contentStackView.addArrangedSubview(makeSectionStackView(section))
            
            if index < settingSections.count - 1 {
                contentStackView.addArrangedSubview(makeDividerLineView())
            }
        }
    }
    
    override func setLayout() {
        titleLabel.snp.makeConstraints {
            $0.top.equalTo(safeAreaLayoutGuide).offset(16)
            $0.leading.equalToSuperview().inset(16)
        }
        
        contentStackView.snp.makeConstraints {
            $0.top.equalTo(titleLabel.snp.bottom).offset(40)
            $0.horizontalEdges.equalToSuperview().inset(24)
        }
    }
    
    // MARK: - Private Methods
    
    private func makeSectionStackView(_ section: SettingSection) -> UIStackView {
        let stackView = UIStackView().then {
            $0.axis = .vertical
            $0.spacing = 12
        }
        let titleLabel = makeSectionTitleLabel(section.title)
        
        stackView.addArrangedSubview(titleLabel)
        stackView.setCustomSpacing(20, after: titleLabel)
        
        section.items.forEach {
            stackView.addArrangedSubview(makeItemView($0))
        }
        
        return stackView
    }
    
    private func makeSectionTitleLabel(_ title: String) -> UILabel {
        UILabel().then {
            $0.text = title
            $0.textColor = .staticWhite
            $0.font = .title_sb_18
        }
    }
    
    private func makeItemView(_ item: SettingItem) -> UIControl {
        let itemView = UIControl()
        let titleLabel = UILabel()
        let chevronImageView = UIImageView()
        
        itemView.do {
            $0.isUserInteractionEnabled = item.action != nil
            
            if let action = item.action {
                $0.tag = action.rawValue
                $0.addTarget(
                    self,
                    action: #selector(itemViewTapped(_:)),
                    for: .touchUpInside
                )
            }
        }
        
        titleLabel.do {
            $0.text = item.title
            $0.textColor = .staticWhite
            $0.font = .label_m_16
        }
        
        chevronImageView.do {
            $0.image = UIImage(named: "ic_chevron_right_sm_white")
            $0.contentMode = .scaleAspectFit
        }
        
        itemView.addSubviews(titleLabel, chevronImageView)
        
        itemView.snp.makeConstraints {
            $0.height.equalTo(33)
        }
        
        titleLabel.snp.makeConstraints {
            $0.leading.centerY.equalToSuperview()
        }
        
        chevronImageView.snp.makeConstraints {
            $0.trailing.centerY.equalToSuperview()
            $0.size.equalTo(24)
        }
        
        return itemView
    }
    
    private func makeDividerLineView() -> UIView {
        UIView().then {
            $0.backgroundColor = .grey500
            
            $0.snp.makeConstraints {
                $0.height.equalTo(1)
            }
        }
    }
    
    // MARK: - Actions
    
    @objc
    private func itemViewTapped(_ sender: UIControl) {
        guard let action = SettingAction(rawValue: sender.tag) else { return }
        
        switch action {
        case .instagram:
            instagramButtonAction?()
        case .logout:
            logoutButtonAction?()
        }
    }
}
