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

    var profileChangeButtonAction: (() -> Void)?
    var instagramButtonAction: (() -> Void)?
    var contactButtonAction: (() -> Void)?
    var logoutButtonAction: (() -> Void)?
    var withdrawButtonAction: (() -> Void)?

    // MARK: - UI Properties

    private let backgroundGradientView = RouteeEllipseBackground()
    private let titleLabel = UILabel()
    private let contentStackView = UIStackView()
    private let routeeSectionView = SettingSection()
    private let policySectionView = SettingSection()
    private let appInfoSectionView = SettingSection()

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
            $0.spacing = 12
        }

        routeeSectionView.configure(
            title: "루티 이용하기",
            itemTitles: [
                "프로필 변경",
                "1:1 문의하기",
                "루티 인스타그램 바로가기"
            ]
        )

        policySectionView.configure(
            title: "이용정책",
            itemTitles: [
                "이용약관",
                "개인정보 처리방침",
                "위치기반 서비스 이용약관"
            ]
        )

        appInfoSectionView.configure(
            title: "앱 정보",
            items: [
                (title: "버전정보", trailingText: appVersionText),
                (title: "로그아웃", trailingText: nil),
                (title: "회원탈퇴", trailingText: nil)
            ]
        )
    }

    override func setUI() {
        addSubviews(backgroundGradientView, titleLabel, contentStackView)

        contentStackView.addArrangedSubviews(
            routeeSectionView,
            policySectionView,
            appInfoSectionView
        )

        setItemActions()
    }

    override func setLayout() {
        backgroundGradientView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }

        titleLabel.snp.makeConstraints {
            $0.top.equalTo(safeAreaLayoutGuide).offset(16)
            $0.leading.equalTo(contentStackView.snp.leading)
        }

        contentStackView.snp.makeConstraints {
            $0.centerX.equalToSuperview()
            $0.top.equalTo(titleLabel.snp.bottom).offset(40)
            $0.width.equalTo(343)
        }
    }

    // MARK: - Private Methods

    private func setItemActions() {
        routeeSectionView.setAction(index: 0, target: self, action: #selector(profileChangeItemTapped))
        routeeSectionView.setAction(index: 1, target: self, action: #selector(contactItemTapped))
        routeeSectionView.setAction(index: 2, target: self, action: #selector(instagramItemTapped))
        appInfoSectionView.setAction(index: 1, target: self, action: #selector(logoutItemTapped))
        appInfoSectionView.setAction(index: 2, target: self, action: #selector(withdrawItemTapped))
    }

    private var appVersionText: String {
        Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? ""
    }

    // MARK: - Actions

    @objc
    private func profileChangeItemTapped() {
        profileChangeButtonAction?()
    }

    @objc
    private func instagramItemTapped() {
        instagramButtonAction?()
    }

    @objc
    private func contactItemTapped() {
        contactButtonAction?()
    }

    @objc
    private func logoutItemTapped() {
        logoutButtonAction?()
    }

    @objc
    private func withdrawItemTapped() {
        withdrawButtonAction?()
    }
}
