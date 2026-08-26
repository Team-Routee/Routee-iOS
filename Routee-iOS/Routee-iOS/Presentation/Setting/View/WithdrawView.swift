//
//  WithdrawView.swift
//  Routee-iOS
//
//  Created by 초긍정행운의포춘쿠키 on 8/26/26.
//

import UIKit

import SnapKit
import Then

final class WithdrawView: BaseUIView {

    // MARK: - Properties

    var backButtonAction: (() -> Void)?
    var kakaoButtonAction: (() -> Void)?
    var emailButtonAction: (() -> Void)?
    var withdrawButtonAction: (() -> Void)?

    private var isAgreed = false {
        didSet {
            updateAgreementState()
        }
    }

    // MARK: - UI Properties

    private let backgroundGradientView = RouteeEllipseBackground()
    private let topNavigationBar = TopNavigationBar(title: "회원 탈퇴")
    private let titleLabel = UILabel()
    private let warningContainerView = UIView()
    private let warningHeaderStackView = UIStackView()
    private let warningIconImageView = UIImageView()
    private let warningTitleLabel = UILabel()
    private let warningDescriptionStackView = UIStackView()
    private let warningPrimaryDescriptionLabel = UILabel()
    private let warningSecondaryDescriptionLabel = UILabel()
    private let inquiryContainerView = UIView()
    private let inquiryTitleLabel = UILabel()
    private let kakaoInquiryItemView = WithdrawInquiryItem(iconImage: .icKakaoCircle, title: "카카오톡 문의하기")
    private let emailInquiryItemView = WithdrawInquiryItem(iconImage: .icEmailCircle, title: "이메일 문의하기")
    private let inquiryDividerView = UIView()
    private let agreementButton = UIButton()
    private let agreementLabel = UILabel()
    private let withdrawButton = RouteeButton(titleText: "루티 탈퇴하기", type: .disabled)

    // MARK: - UI Setting

    override func setStyle() {
        backgroundColor = .bgPrimary

        titleLabel.do {
            $0.text = "회원 탈퇴하시겠습니까?"
            $0.textColor = .staticWhite
            $0.font = .title_sb_20
        }
        
        warningContainerView.do {
            $0.backgroundColor = .grey900
            $0.layer.cornerRadius = .r12
        }

        inquiryContainerView.do {
            $0.backgroundColor = .grey900
            $0.layer.cornerRadius = .r12
        }
        
        warningHeaderStackView.do {
            $0.axis = .horizontal
            $0.alignment = .center
            $0.spacing = .s6
        }

        warningIconImageView.do {
            $0.image = .icError
            $0.contentMode = .scaleAspectFit
        }

        warningTitleLabel.do {
            $0.text = "회원 탈퇴할 경우"
            $0.textColor = .statusError
            $0.font = .label_m_14
        }

        warningDescriptionStackView.do {
            $0.axis = .vertical
            $0.spacing = .s8
        }

        warningPrimaryDescriptionLabel.do {
            $0.text = """
            루티 앱 계정의 모든 데이터가 삭제되며, 복구가 불가능합니다.
            중요한 정보가 있는지 다시 한 번 확인해주세요.
            """
            $0.textColor = .grey200
            $0.font = .label_m_12
            $0.numberOfLines = 2
        }

        warningSecondaryDescriptionLabel.do {
            $0.text = """
            그러나 언제든지 마음이 바뀌면 돌아오셔서 새로운 루티 계정을
            만들어 소중한 경험을 이어나갈 수 있습니다.
            """
            $0.textColor = .grey200
            $0.font = .label_m_12
            $0.numberOfLines = 2
        }

        inquiryTitleLabel.do {
            $0.text = "혹시, 루티 이용의 불편함이 있으시다면 알려주세요."
            $0.textColor = .staticWhite
            $0.font = .label_m_14
        }

        inquiryDividerView.backgroundColor = .grey600

        agreementButton.do {
            $0.setImage(UIImage(resource: .btnUnchecked), for: .normal)
            $0.setImage(UIImage(resource: .btnChecked), for: .selected)
        }

        agreementLabel.do {
            $0.text = "모든 것에 동의하고 탈퇴하겠습니다."
            $0.textColor = .staticWhite
            $0.font = .label_r_14
        }
    }

    override func setUI() {
        addSubviews(
            backgroundGradientView,
            topNavigationBar,
            titleLabel,
            warningContainerView,
            inquiryContainerView,
            agreementButton,
            agreementLabel,
            withdrawButton
        )

        warningContainerView.addSubviews(
            warningHeaderStackView,
            warningDescriptionStackView
        )
        warningHeaderStackView.addArrangedSubviews(
            warningIconImageView,
            warningTitleLabel
        )
        warningDescriptionStackView.addArrangedSubviews(
            warningPrimaryDescriptionLabel,
            warningSecondaryDescriptionLabel
        )

        inquiryContainerView.addSubviews(
            inquiryTitleLabel,
            kakaoInquiryItemView,
            inquiryDividerView,
            emailInquiryItemView
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
            $0.leading.equalTo(warningContainerView.snp.leading)
        }

        warningContainerView.snp.makeConstraints {
            $0.top.equalTo(titleLabel.snp.bottom).offset(18)
            $0.centerX.equalToSuperview()
            $0.width.equalTo(343)
            $0.height.equalTo(150)
        }

        warningHeaderStackView.snp.makeConstraints {
            $0.top.leading.equalToSuperview().inset(18)
        }

        warningIconImageView.snp.makeConstraints {
            $0.size.equalTo(24)
        }

        warningDescriptionStackView.snp.makeConstraints {
            $0.top.equalTo(warningHeaderStackView.snp.bottom).offset(14)
            $0.leading.equalTo(warningHeaderStackView.snp.leading)
            $0.width.equalTo(307)
        }

        inquiryContainerView.snp.makeConstraints {
            $0.top.equalTo(warningContainerView.snp.bottom).offset(12)
            $0.centerX.equalToSuperview()
            $0.width.equalTo(343)
            $0.height.equalTo(150)
        }

        inquiryTitleLabel.snp.makeConstraints {
            $0.top.leading.equalToSuperview().inset(18)
        }

        kakaoInquiryItemView.snp.makeConstraints {
            $0.top.equalTo(inquiryTitleLabel.snp.bottom).offset(8)
            $0.centerX.equalToSuperview()
            $0.width.equalTo(307)
            $0.height.equalTo(50)
        }

        inquiryDividerView.snp.makeConstraints {
            $0.top.equalTo(kakaoInquiryItemView.snp.bottom).offset(-1)
            $0.centerX.equalToSuperview()
            $0.width.equalTo(307)
            $0.height.equalTo(1)
        }

        emailInquiryItemView.snp.makeConstraints {
            $0.top.equalTo(inquiryDividerView.snp.bottom)
            $0.centerX.equalToSuperview()
            $0.width.equalTo(307)
            $0.height.equalTo(50)
        }

        withdrawButton.snp.makeConstraints {
            $0.bottom.equalTo(safeAreaLayoutGuide).inset(28)
            $0.centerX.equalToSuperview()
        }

        agreementButton.snp.makeConstraints {
            $0.leading.equalTo(withdrawButton.snp.leading).offset(10)
            $0.bottom.equalTo(withdrawButton.snp.top).offset(-24)
            $0.size.equalTo(24)
        }

        agreementLabel.snp.makeConstraints {
            $0.leading.equalTo(agreementButton.snp.trailing).offset(12)
            $0.centerY.equalTo(agreementButton)
        }
    }

    // MARK: - Private Methods

    private func setAddTarget() {
        topNavigationBar.backButtonAction = { [weak self] in
            self?.backButtonAction?()
        }

        kakaoInquiryItemView.addTarget(self, action: #selector(didTapKakaoInquiryItem), for: .touchUpInside)
        emailInquiryItemView.addTarget(self, action: #selector(didTapEmailInquiryItem), for: .touchUpInside)
        agreementButton.addTarget(self, action: #selector(didTapAgreementButton), for: .touchUpInside)
        withdrawButton.addTarget(self, action: #selector(didTapWithdrawButton), for: .touchUpInside)
    }

    private func updateAgreementState() {
        agreementButton.isSelected = isAgreed
        withdrawButton.updateType(isAgreed ? .enabled : .disabled)
    }

    // MARK: - Actions

    @objc
    private func didTapKakaoInquiryItem() {
        kakaoButtonAction?()
    }

    @objc
    private func didTapEmailInquiryItem() {
        emailButtonAction?()
    }

    @objc
    private func didTapAgreementButton() {
        isAgreed.toggle()
    }

    @objc
    private func didTapWithdrawButton() {
        withdrawButtonAction?()
    }
}

extension WithdrawView: SettingToastPresentable { }
