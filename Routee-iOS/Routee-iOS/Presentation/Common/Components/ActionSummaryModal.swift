//
//  ActionSummaryModal.swift
//  Routee-iOS
//
//  Created by LEESANGYUP on 11/11/26.
//

import UIKit

import SnapKit
import Then

final class ActionSummaryModal: UIViewController {

    struct Action {
        let title: String
        let handler: () -> Void
    }

    // MARK: - Properties

    private let titleText: String
    private let subtitle: String?
    private let detail: String?
    private let closeAccessibilityLabel: String
    private let onClose: (() -> Void)?
    private let secondaryAction: Action
    private let primaryAction: Action

    // MARK: - UI Properties

    private let cardView = UIView()
    private let closeButton = UIButton()
    private let summaryStackView = UIStackView()
    private let titleLabel = UILabel()
    private let subtitleLabel = UILabel()
    private let detailLabel = UILabel()
    private let buttonStackView = UIStackView()
    private let secondaryButton = UIButton()
    private let primaryButton = UIButton()

    // MARK: - Initializer

    init(
        title: String,
        subtitle: String? = nil,
        detail: String? = nil,
        closeAccessibilityLabel: String = "닫기",
        onClose: (() -> Void)? = nil,
        secondaryAction: Action,
        primaryAction: Action
    ) {
        titleText = title
        self.subtitle = subtitle
        self.detail = detail
        self.closeAccessibilityLabel = closeAccessibilityLabel
        self.onClose = onClose
        self.secondaryAction = secondaryAction
        self.primaryAction = primaryAction

        super.init(nibName: nil, bundle: nil)

        modalPresentationStyle = .overFullScreen
        modalTransitionStyle = .crossDissolve
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Life Cycle

    override func viewDidLoad() {
        super.viewDidLoad()

        setStyle()
        setUI()
        setLayout()
        setAddTarget()
    }

    // MARK: - UI Setting

    private func setStyle() {
        view.backgroundColor = .dim_secondary
        view.accessibilityViewIsModal = true

        cardView.do {
            $0.backgroundColor = .grey_800
            $0.layer.cornerRadius = .r24
        }

        closeButton.do {
            $0.setImage(.icCancelSmOutline, for: .normal)
            $0.backgroundColor = .white_10
            $0.layer.cornerRadius = .r12
            $0.accessibilityLabel = closeAccessibilityLabel
        }

        summaryStackView.do {
            $0.axis = .vertical
            $0.spacing = 4
        }

        titleLabel.do {
            $0.text = titleText
            $0.font = .title_sb_18
            $0.textColor = .staticWhite
            $0.textAlignment = .center
            $0.numberOfLines = 0
            $0.accessibilityTraits.insert(.header)
        }

        subtitleLabel.do {
            $0.text = subtitle
            $0.isHidden = subtitle == nil
            $0.font = .label_m_14
            $0.textColor = .grey_300
            $0.textAlignment = .center
            $0.numberOfLines = 0
        }

        detailLabel.do {
            $0.text = detail
            $0.isHidden = detail == nil
            $0.font = .label_sb_16
            $0.textColor = .staticWhite
            $0.textAlignment = .center
            $0.numberOfLines = 0
        }

        buttonStackView.do {
            $0.axis = .horizontal
            $0.distribution = .fillEqually
            $0.spacing = 8
        }

        configureButton(secondaryButton, title: secondaryAction.title, titleColor: .white_60, backgroundColor: .white_10)
        configureButton(primaryButton, title: primaryAction.title, titleColor: .staticBlack, backgroundColor: .bgCtaPrimary)
    }

    private func setUI() {
        view.addSubview(cardView)
        cardView.addSubviews(closeButton, summaryStackView, buttonStackView)
        summaryStackView.addArrangedSubviews(titleLabel, subtitleLabel, detailLabel)
        buttonStackView.addArrangedSubviews(secondaryButton, primaryButton)
    }

    private func setLayout() {
        cardView.snp.makeConstraints {
            $0.center.equalToSuperview()
            $0.width.equalToSuperview().offset(-48).priority(.high)
            $0.width.lessThanOrEqualTo(318)
        }

        closeButton.snp.makeConstraints {
            $0.top.equalToSuperview().inset(12)
            $0.trailing.equalToSuperview().inset(24)
            $0.size.equalTo(28)
        }

        summaryStackView.snp.makeConstraints {
            $0.top.equalTo(closeButton.snp.bottom).offset(8)
            $0.horizontalEdges.equalToSuperview().inset(24)
        }

        buttonStackView.snp.makeConstraints {
            $0.top.equalTo(summaryStackView.snp.bottom).offset(16)
            $0.horizontalEdges.equalToSuperview().inset(24)
            $0.bottom.equalToSuperview().inset(24)
            $0.height.equalTo(46)
        }
    }

    private func setAddTarget() {
        closeButton.addTarget(self, action: #selector(didTapClose), for: .touchUpInside)
        secondaryButton.addTarget(self, action: #selector(didTapSecondary), for: .touchUpInside)
        primaryButton.addTarget(self, action: #selector(didTapPrimary), for: .touchUpInside)
    }

    // MARK: - Private Methods

    private func configureButton(_ button: UIButton, title: String, titleColor: UIColor, backgroundColor: UIColor) {
        button.do {
            $0.setTitle(title, for: .normal)
            $0.setTitleColor(titleColor, for: .normal)
            $0.titleLabel?.font = .label_sb_16
            $0.backgroundColor = backgroundColor
            $0.layer.cornerRadius = 23
        }
    }

    private func dismissAndPerform(_ action: (() -> Void)?) {
        guard !isBeingDismissed else { return }
        dismiss(animated: true, completion: action)
    }

    // MARK: - Actions

    @objc
    private func didTapClose() {
        dismissAndPerform(onClose)
    }

    @objc
    private func didTapSecondary() {
        dismissAndPerform(secondaryAction.handler)
    }

    @objc
    private func didTapPrimary() {
        dismissAndPerform(primaryAction.handler)
    }
}
