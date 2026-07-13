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

    // MARK: - UI Properties

    private let backgroundGradientView = RouteeEllipseBackground()
    private let titleLabel = UILabel()
    private let contentStackView = UIStackView()
    private let routeeSectionView = SettingSectionView()
    private let routeeDividerLineView = UIView()
    private let policySectionView = SettingSectionView()
    private let policyDividerLineView = UIView()
    private let appInfoSectionView = SettingSectionView()

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
            $0.spacing = 28
        }

        routeeSectionView.configure(
            model: .init(
                title: "루티 이용하기",
                itemTitles: [
                    "공지사항",
                    "1:1 문의하기",
                    "루티 인스타그램 바로가기"
                ]
            )
        )

        policySectionView.configure(
            model: .init(
                title: "이용정책",
                itemTitles: [
                    "이용약관",
                    "개인정보 처리방침",
                    "위치기반 서비스 이용약관"
                ]
            )
        )

        appInfoSectionView.configure(
            model: .init(
                title: "앱 정보",
                itemTitles: [
                    "버전정보",
                    "로그아웃"
                ]
            )
        )

        [
            routeeDividerLineView,
            policyDividerLineView
        ].forEach {
            $0.backgroundColor = .grey500
        }
    }

    override func setUI() {
        addSubviews(backgroundGradientView, titleLabel, contentStackView)

        contentStackView.addArrangedSubviews(
            routeeSectionView,
            routeeDividerLineView,
            policySectionView,
            policyDividerLineView,
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
            $0.leading.equalToSuperview().inset(16)
        }

        contentStackView.snp.makeConstraints {
            $0.top.equalTo(titleLabel.snp.bottom).offset(40)
            $0.horizontalEdges.equalToSuperview().inset(24)
        }

        [
            routeeDividerLineView,
            policyDividerLineView
        ].forEach {
            $0.snp.makeConstraints {
                $0.height.equalTo(1)
            }
        }
    }

    // MARK: - Private Methods

    private func setItemActions() {
        routeeSectionView.setAction(index: 2, target: self, action: #selector(instagramItemTapped))
        appInfoSectionView.setAction(index: 1, target: self, action: #selector(logoutItemTapped))
    }

    // MARK: - Actions

    @objc
    private func instagramItemTapped() {
        instagramButtonAction?()
    }

    @objc
    private func logoutItemTapped() {
        logoutButtonAction?()
    }
}
