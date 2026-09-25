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
    var termsOfServiceButtonAction: (() -> Void)?
    var privacyPolicyButtonAction: (() -> Void)?
    var locationTermsButtonAction: (() -> Void)?
    var logoutButtonAction: (() -> Void)?
    var withdrawButtonAction: (() -> Void)?

    // MARK: - UI Properties

    private let backgroundGradientView = RouteeEllipseBackground()
    private let titleLabel = UILabel()
    private let scrollView = UIScrollView()
    private let contentView = UIView()
    private let contentStackView = UIStackView()
    private let routeeSectionView = SettingSection()
    private let policySectionView = SettingSection()
    private let appInfoSectionView = SettingSection()

    // MARK: - UI Setting

    override func setStyle() {
        backgroundColor = .bgPrimary

        scrollView.showsVerticalScrollIndicator = false
        scrollView.alwaysBounceVertical = true
        scrollView.contentInsetAdjustmentBehavior = .never

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
            ],
            hidesChevronAt: [0]
        )
    }

    override func setUI() {
        addSubviews(backgroundGradientView, titleLabel, scrollView)
        scrollView.addSubview(contentView)
        contentView.addSubview(contentStackView)

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
            $0.centerX.equalToSuperview()
            $0.width.equalTo(343)
        }

        scrollView.snp.makeConstraints {
            $0.top.equalTo(titleLabel.snp.bottom)
            $0.horizontalEdges.equalToSuperview()
            $0.bottom.equalTo(safeAreaLayoutGuide)
        }

        contentView.snp.makeConstraints {
            $0.edges.equalTo(scrollView.contentLayoutGuide)
            $0.width.equalTo(scrollView.frameLayoutGuide)
        }

        contentStackView.snp.makeConstraints {
            $0.centerX.equalToSuperview()
            $0.top.equalToSuperview().offset(33)
            $0.width.equalTo(343)
            $0.bottom.equalToSuperview().inset(16)
        }
    }

    // MARK: - Private Methods

    private func setItemActions() {
        routeeSectionView.setAction(index: 0, target: self, action: #selector(profileChangeItemTapped))
        routeeSectionView.setAction(index: 1, target: self, action: #selector(contactItemTapped))
        routeeSectionView.setAction(index: 2, target: self, action: #selector(instagramItemTapped))
        policySectionView.setAction(index: 0, target: self, action: #selector(termsOfServiceItemTapped))
        policySectionView.setAction(index: 1, target: self, action: #selector(privacyPolicyItemTapped))
        policySectionView.setAction(index: 2, target: self, action: #selector(locationTermsItemTapped))
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
    private func termsOfServiceItemTapped() {
        termsOfServiceButtonAction?()
    }

    @objc
    private func privacyPolicyItemTapped() {
        privacyPolicyButtonAction?()
    }

    @objc
    private func locationTermsItemTapped() {
        locationTermsButtonAction?()
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
