//
//  ActionVerticalModal.swift
//  Routee-iOS
//
//  Created by 김세령 on 8/17/26.
//

import UIKit

import SnapKit
import Then

final class ActionVerticalModal: UIViewController {

    // MARK: - Properties

    private let titleText: String
    private let topButtonTitle: String
    private let bottomButtonTitle: String
    private let dismissOnAction: Bool
    private let topButtonAction: (() -> Void)?
    private let bottomButtonAction: (() -> Void)?
    private let closeButtonAction: (() -> Void)?

    // MARK: - UI Properties

    private let dimBackgroundView = UIControl()
    private let modalView = UIView()
    private let closeButton = UIButton()
    private let titleContainerView = UIView()
    private let titleLabel = UILabel()
    private let buttonStackView = UIStackView()
    private let topButton = UIButton()
    private let bottomButton = UIButton()

    // MARK: - Initializer

    init(
        title: String,
        topButtonTitle: String,
        bottomButtonTitle: String,
        dismissOnAction: Bool = true,
        topButtonAction: (() -> Void)? = nil,
        bottomButtonAction: (() -> Void)? = nil,
        closeButtonAction: (() -> Void)? = nil
    ) {
        self.titleText = title
        self.topButtonTitle = topButtonTitle
        self.bottomButtonTitle = bottomButtonTitle
        self.dismissOnAction = dismissOnAction
        self.topButtonAction = topButtonAction
        self.bottomButtonAction = bottomButtonAction
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

        dimBackgroundView.do {
            $0.backgroundColor = .dim_secondary
        }

        modalView.do {
            $0.backgroundColor = .grey_800
            $0.layer.cornerRadius = .r24
            $0.clipsToBounds = true
        }

        closeButton.do {
            let image = UIImage(named: "ic_cancel_sm_outline")
            $0.setImage(image, for: .normal)
            $0.backgroundColor = .white_10
            $0.layer.cornerRadius = .r12
            $0.clipsToBounds = true
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
            $0.spacing = 10
            $0.distribution = .fill
        }

        configureButton(topButton, title: topButtonTitle)
        configureButton(bottomButton, title: bottomButtonTitle)
    }

    private func setUI() {
        view.addSubviews(dimBackgroundView, modalView)
        modalView.addSubviews(titleContainerView, buttonStackView, closeButton)

        titleContainerView.addSubview(titleLabel)
        buttonStackView.addArrangedSubview(topButton)
        buttonStackView.addArrangedSubview(bottomButton)
    }

    private func setLayout() {
        dimBackgroundView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }

        modalView.snp.makeConstraints {
            $0.center.equalToSuperview()
            $0.width.equalToSuperview()
                .offset(-48)
                .priority(.high)
            $0.width.lessThanOrEqualTo(318)
            $0.height.equalTo(211)
        }

        closeButton.snp.makeConstraints {
            $0.top.equalToSuperview().inset(20)
            $0.trailing.equalToSuperview().inset(24)
            $0.size.equalTo(24)
        }

        titleContainerView.snp.makeConstraints {
            $0.top.equalTo(closeButton.snp.bottom)
            $0.horizontalEdges.equalToSuperview()
                .inset(24)
            $0.height.equalTo(41)
        }

        titleLabel.snp.makeConstraints {
            $0.top.equalToSuperview()
            $0.horizontalEdges.equalToSuperview()
                .inset(16)
            $0.bottom.equalToSuperview().inset(16)
        }

        buttonStackView.snp.makeConstraints {
            $0.top.equalTo(titleContainerView.snp.bottom)
            $0.horizontalEdges.equalToSuperview()
                .inset(24)
            $0.bottom.equalToSuperview().inset(24)
        }

        topButton.snp.makeConstraints {
            $0.height.equalTo(46)
        }

        bottomButton.snp.makeConstraints {
            $0.height.equalTo(46)
        }
    }

    private func setAddTarget() {
        dimBackgroundView.addTarget(self, action: #selector(didTapDimBackground), for: .touchUpInside)
        closeButton.addTarget(self, action: #selector(didTapCloseButton), for: .touchUpInside)
        topButton.addTarget(self, action: #selector(didTapTopButton), for: .touchUpInside)
        bottomButton.addTarget(self, action: #selector(didTapBottomButton), for: .touchUpInside)
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
    private func didTapDimBackground() {
        dismiss(animated: true)
    }

    @objc
    private func didTapCloseButton() {
        dismiss(animated: true) { [closeButtonAction] in
            closeButtonAction?()
        }
    }

    @objc
    private func didTapTopButton() {
        performAction(topButtonAction)
    }

    @objc
    private func didTapBottomButton() {
        performAction(bottomButtonAction)
    }
}
