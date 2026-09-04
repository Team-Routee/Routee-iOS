//
//  TermsAgreementView.swift
//  Routee-iOS
//
//  Created by LEESANGYUP on 8/26/26.
//

import UIKit

import SnapKit
import Then

final class TermsAgreementView: BaseUIView {

    // MARK: - UI Properties

    private let topNavigationBar = TopNavigationBar()
    private let backgroundImageView = RouteeEllipseBackground()
    private let titleLabel = UILabel()
    private let dividerView = UIView()
    private let agreementStackView = UIStackView()

    let allAgreementButton = CheckBoxButton(
        titleText: "모두 동의합니다.",
        prefixStyle: .none,
        showsChevron: false,
        fontStyle: .labelSB16
    )

    let serviceTermsButton = CheckBoxButton(
        titleText: "서비스 이용약관",
        prefixStyle: .required,
        showsChevron: true,
        fontStyle: .labelR14
    )

    let privacyPolicyButton = CheckBoxButton(
        titleText: "개인정보 처리방침",
        prefixStyle: .required,
        showsChevron: true,
        fontStyle: .labelR14
    )

    let locationTermsButton = CheckBoxButton(
        titleText: "위치기반 서비스 이용약관",
        prefixStyle: .required,
        showsChevron: true,
        fontStyle: .labelR14
    )

    let ageRequirementButton = CheckBoxButton(
        titleText: "만 14세 이상입니다",
        prefixStyle: .required,
        showsChevron: false,
        fontStyle: .labelR14
    )

    let marketingConsentButton = CheckBoxButton(
        titleText: "마케팅 활용 및 광고성 정보 수신 동의",
        prefixStyle: .optional,
        showsChevron: false,
        fontStyle: .labelR14
    )
    
    lazy var nextButton = RouteeButton(titleText: "다음", type: .disabled)

    var backButtonAction: (() -> Void)? {
        get { topNavigationBar.backButtonAction }
        set { topNavigationBar.backButtonAction = newValue }
    }

    var hasAgreedToRequiredTerms: Bool {
        requiredAgreementButtons.allSatisfy(\.isChecked)
    }

    var agreements: RegisterInfoModel.Agreements {
        RegisterInfoModel.Agreements(
            serviceTerms: serviceTermsButton.isChecked,
            privacyPolicy: privacyPolicyButton.isChecked,
            locationServiceTerms: locationTermsButton.isChecked,
            over14: ageRequirementButton.isChecked,
            marketingConsent: marketingConsentButton.isChecked
        )
    }

    private var individualAgreementButtons: [CheckBoxButton] {
        [
            serviceTermsButton,
            privacyPolicyButton,
            locationTermsButton,
            ageRequirementButton,
            marketingConsentButton
        ]
    }

    private var requiredAgreementButtons: [CheckBoxButton] {
        [
            serviceTermsButton,
            privacyPolicyButton,
            locationTermsButton,
            ageRequirementButton
        ]
    }

    // MARK: - UI Setting

    override func setStyle() {
        backgroundColor = .bgPrimary
        topNavigationBar.setBackButtonHidden(false)
        dividerView.backgroundColor = .grey600
        
        titleLabel.do {
            $0.text = "서비스 이용 약관에 동의해 주세요."
            $0.font = .title_sb_20
            $0.textColor = .staticWhite
        }

        agreementStackView.do {
            $0.axis = .vertical
            $0.spacing = 24
        }
    }

    override func setUI() {
        addSubviews(
            backgroundImageView,
            topNavigationBar,
            titleLabel,
            allAgreementButton,
            dividerView,
            agreementStackView,
            nextButton
        )

        individualAgreementButtons.forEach {
            agreementStackView.addArrangedSubview($0)
            $0.addTarget(
                self,
                action: #selector(individualAgreementDidChange),
                for: .valueChanged
            )
        }

        allAgreementButton.addTarget(
            self,
            action: #selector(allAgreementDidChange),
            for: .valueChanged
        )
    }

    override func setLayout() {
        backgroundImageView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
        
        topNavigationBar.snp.makeConstraints {
            $0.top.equalTo(safeAreaLayoutGuide)
            $0.horizontalEdges.equalToSuperview()
        }
        
        titleLabel.snp.makeConstraints {
            $0.top.equalTo(topNavigationBar.snp.bottom).offset(102)
            $0.centerX.equalToSuperview()
        }
        
        allAgreementButton.snp.makeConstraints {
            $0.top.equalTo(titleLabel.snp.bottom).offset(52)
            $0.horizontalEdges.equalToSuperview().inset(28)
        }

        dividerView.snp.makeConstraints {
            $0.top.equalTo(allAgreementButton.snp.bottom).offset(20)
            $0.horizontalEdges.equalToSuperview().inset(28)
            $0.height.equalTo(1)
        }

        agreementStackView.snp.makeConstraints {
            $0.top.equalTo(dividerView.snp.bottom).offset(20)
            $0.horizontalEdges.equalToSuperview().inset(28)
        }
        
        nextButton.snp.makeConstraints {
            $0.bottom.equalTo(safeAreaLayoutGuide).inset(75)
            $0.centerX.equalToSuperview()
            $0.width.equalTo(343)
        }
    }

    // MARK: - Actions

    @objc
    private func allAgreementDidChange() {
        individualAgreementButtons.forEach {
            $0.isChecked = allAgreementButton.isChecked
        }

        updateNextButtonState()
    }

    @objc
    private func individualAgreementDidChange() {
        allAgreementButton.isChecked = individualAgreementButtons.allSatisfy(\.isChecked)
        updateNextButtonState()
    }

    private func updateNextButtonState() {
        nextButton.updateType(hasAgreedToRequiredTerms ? .enabled : .disabled)
    }
}
