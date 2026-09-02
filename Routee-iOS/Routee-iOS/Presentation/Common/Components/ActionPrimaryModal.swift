//
//  ActionPrimaryModal.swift
//  Routee-iOS
//
//  Created by 김세령 on 8/17/26.
//

import UIKit

import SnapKit
import Then

final class ActionPrimaryModal: UIViewController {

    enum ActionCount {
        case single
        case double
    }

    // MARK: - Properties

    private let titleText: String
    private let descriptionText: String?
    private let actionCount: ActionCount
    private let leftButtonTitle: String
    private let rightButtonTitle: String
    private let dismissOnAction: Bool
    private let leftButtonAction: (() -> Void)?
    private let rightButtonAction: (() -> Void)?
    private var hasDescription: Bool {
        !(descriptionText?.isEmpty ?? true)
    }

    // MARK: - UI Properties

    private let dimBackgroundView = UIControl()
    private let modalView = UIView()
    private let contentStackView = UIStackView()
    private let textStackView = UIStackView()
    private let titleLabel = UILabel()
    private let descriptionLabel = UILabel()
    private let buttonStackView = UIStackView()
    private let leftButton = UIButton()
    private let rightButton = UIButton()

    // MARK: - Initializer

    init(
        title: String,
        description: String? = nil,
        actionCount: ActionCount = .double,
        leftButtonTitle: String = "",
        rightButtonTitle: String = "",
        dismissOnAction: Bool = true,
        leftButtonAction: (() -> Void)? = nil,
        rightButtonAction: (() -> Void)? = nil
    ) {
        self.titleText = title
        self.descriptionText = description
        self.actionCount = actionCount
        self.leftButtonTitle = leftButtonTitle
        self.rightButtonTitle = rightButtonTitle
        self.dismissOnAction = dismissOnAction
        self.leftButtonAction = leftButtonAction
        self.rightButtonAction = rightButtonAction

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
        view.backgroundColor = .clear

        dimBackgroundView.do {
            $0.backgroundColor = .dim_secondary
        }

        modalView.do {
            $0.backgroundColor = .grey_800
            $0.layer.cornerRadius = .r24
            $0.clipsToBounds = true
        }

        contentStackView.do {
            $0.axis = .vertical
            $0.alignment = .fill
        }

        textStackView.do {
            $0.axis = .vertical
            $0.alignment = .fill
            $0.spacing = .s8
            $0.layoutMargins = UIEdgeInsets(
                top: .s8,
                left: .s8,
                bottom: .s16,
                right: .s8
            )
            $0.isLayoutMarginsRelativeArrangement = true
        }

        titleLabel.do {
            $0.text = titleText
            $0.textColor = .white
            $0.font = .title_sb_18
            $0.textAlignment = .center
            $0.numberOfLines = 0
        }

        descriptionLabel.do {
            $0.text = descriptionText
            $0.textColor = .grey_300
            $0.font = .label_m_14
            $0.textAlignment = .center
            $0.numberOfLines = 0
            $0.isHidden = !hasDescription
        }

        buttonStackView.do {
            $0.axis = .horizontal
            $0.spacing = .s8
            $0.distribution = .fillEqually
        }

        configureButton(
            leftButton,
            title: leftButtonTitle,
            titleColor: .white_60
        )
        configureButton(
            rightButton,
            title: rightButtonTitle,
            titleColor: .status_error
        )
    }

    private func setUI() {
        view.addSubviews(dimBackgroundView, modalView)
        modalView.addSubview(contentStackView)

        contentStackView.addArrangedSubview(textStackView)
        textStackView.addArrangedSubview(titleLabel)

        if hasDescription {
            textStackView.addArrangedSubview(descriptionLabel)
        }

        contentStackView.addArrangedSubview(buttonStackView)

        switch actionCount {
        case .single:
            buttonStackView.addArrangedSubview(leftButton)
        case .double:
            buttonStackView.addArrangedSubview(leftButton)
            buttonStackView.addArrangedSubview(rightButton)
        }
    }

    private func setLayout() {
        dimBackgroundView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }

        modalView.snp.makeConstraints {
            $0.center.equalToSuperview()
            $0.width.equalToSuperview()
                .offset(-(CGFloat.s24 * 2))
                .priority(.high)
            $0.width.lessThanOrEqualTo(318)
        }

        contentStackView.snp.makeConstraints {
            $0.horizontalEdges.equalToSuperview().inset(CGFloat.s24)
            $0.verticalEdges.equalToSuperview().inset(CGFloat.s24)
        }

        leftButton.snp.makeConstraints {
            $0.height.equalTo(46)
        }
    }

    private func setAddTarget() {
        dimBackgroundView.addTarget(self, action: #selector(didTapDimBackground), for: .touchUpInside)
        leftButton.addTarget(self, action: #selector(didTapLeftButton), for: .touchUpInside)
        rightButton.addTarget(self, action: #selector(didTapRightButton), for: .touchUpInside)
    }

    // MARK: - Private Methods

    private func configureButton(
        _ button: UIButton,
        title: String,
        titleColor: UIColor
    ) {
        button.do {
            $0.setTitle(title, for: .normal)
            $0.setTitleColor(titleColor, for: .normal)
            $0.titleLabel?.font = .label_sb_16
            $0.backgroundColor = .white_10
            $0.layer.cornerRadius = 23
            $0.clipsToBounds = true
        }
    }

    private func performAction(_ action: (() -> Void)?) {
        guard dismissOnAction else {
            action?()
            return
        }

        dismiss(animated: true) {
            action?()
        }
    }

    // MARK: - Actions

    @objc
    private func didTapDimBackground() {
        dismiss(animated: true)
    }

    @objc
    private func didTapLeftButton() {
        performAction(leftButtonAction)
    }

    @objc
    private func didTapRightButton() {
        performAction(rightButtonAction)
    }
}
