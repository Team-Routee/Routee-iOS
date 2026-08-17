//
//  ActionVerticalModal.swift
//  Routee-iOS
//
//  Created by Codex on 8/17/26.
//

import UIKit

import SnapKit
import Then

final class ActionVerticalModal: UIViewController {

    // MARK: - Properties

    private let titleText: String
    private let firstButtonTitle: String
    private let secondButtonTitle: String
    private let dismissOnAction: Bool
    private let firstButtonAction: (() -> Void)?
    private let secondButtonAction: (() -> Void)?
    private let closeButtonAction: (() -> Void)?

    // MARK: - UI Properties

    private let dimButton = UIButton()
    private let modalView = UIView()
    private let closeButton = UIButton()
    private let contentStackView = UIStackView()
    private let titleLabel = UILabel()
    private let buttonStackView = UIStackView()
    private let firstButton = UIButton()
    private let secondButton = UIButton()

    // MARK: - Initializer

    init(
        title: String,
        firstButtonTitle: String,
        secondButtonTitle: String,
        dismissOnAction: Bool = true,
        firstButtonAction: (() -> Void)? = nil,
        secondButtonAction: (() -> Void)? = nil,
        closeButtonAction: (() -> Void)? = nil
    ) {
        self.titleText = title
        self.firstButtonTitle = firstButtonTitle
        self.secondButtonTitle = secondButtonTitle
        self.dismissOnAction = dismissOnAction
        self.firstButtonAction = firstButtonAction
        self.secondButtonAction = secondButtonAction
        self.closeButtonAction = closeButtonAction

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

        dimButton.do {
            $0.backgroundColor = .bg_primary
        }

        modalView.do {
            $0.backgroundColor = .grey_800
            $0.layer.cornerRadius = .r24
            $0.clipsToBounds = true
        }

        closeButton.do {
            let image = UIImage(systemName: "xmark")
            $0.setImage(image, for: .normal)
            $0.tintColor = .white
            $0.backgroundColor = .white_10
            $0.layer.cornerRadius = .r22
            $0.clipsToBounds = true
        }

        contentStackView.do {
            $0.axis = .vertical
            $0.alignment = .fill
        }

        titleLabel.do {
            $0.text = titleText
            $0.textColor = .white
            $0.font = .title_sb_18
            $0.textAlignment = .center
            $0.numberOfLines = 0
        }

        buttonStackView.do {
            $0.axis = .vertical
            $0.spacing = .s16
            $0.distribution = .fill
        }

        configureButton(firstButton, title: firstButtonTitle)
        configureButton(secondButton, title: secondButtonTitle)
    }

    private func setUI() {
        view.addSubviews(dimButton, modalView)
        modalView.addSubviews(contentStackView, closeButton)

        contentStackView.addArrangedSubview(titleLabel)
        contentStackView.setCustomSpacing(
            .s32,
            after: titleLabel
        )
        contentStackView.addArrangedSubview(buttonStackView)

        buttonStackView.addArrangedSubview(firstButton)
        buttonStackView.addArrangedSubview(secondButton)
    }

    private func setLayout() {
        dimButton.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }

        modalView.snp.makeConstraints {
            $0.center.equalToSuperview()
            $0.width.equalToSuperview()
                .offset(-(CGFloat.s24 * 2))
                .priority(.high)
            $0.width.lessThanOrEqualTo(318)
        }

        closeButton.snp.makeConstraints {
            $0.top.trailing.equalToSuperview().inset(CGFloat.s24)
            $0.size.equalTo(44)
        }

        contentStackView.snp.makeConstraints {
            $0.top.equalToSuperview().inset(CGFloat.s80)
            $0.horizontalEdges.equalToSuperview()
                .inset(CGFloat.s24)
            $0.bottom.equalToSuperview().inset(CGFloat.s24)
        }

        firstButton.snp.makeConstraints {
            $0.height.equalTo(46)
        }

        secondButton.snp.makeConstraints {
            $0.height.equalTo(46)
        }
    }

    private func setAddTarget() {
        dimButton.addTarget(self, action: #selector(didTapDimButton), for: .touchUpInside)
        closeButton.addTarget(self, action: #selector(didTapCloseButton), for: .touchUpInside)
        firstButton.addTarget(self, action: #selector(didTapFirstButton), for: .touchUpInside)
        secondButton.addTarget(self, action: #selector(didTapSecondButton), for: .touchUpInside)
    }

    // MARK: - Private Methods

    private func configureButton(_ button: UIButton, title: String) {
        button.do {
            $0.setTitle(title, for: .normal)
            $0.setTitleColor(.white_60, for: .normal)
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
    private func didTapDimButton() {
        dismiss(animated: true)
    }

    @objc
    private func didTapCloseButton() {
        dismiss(animated: true) { [closeButtonAction] in
            closeButtonAction?()
        }
    }

    @objc
    private func didTapFirstButton() {
        performAction(firstButtonAction)
    }

    @objc
    private func didTapSecondButton() {
        performAction(secondButtonAction)
    }
}
