//
//  SnackbarView.swift
//  Routee-iOS
//
//  Created by LEESANGYUP on 8/30/26.
//

import UIKit

import SnapKit
import Then

final class SnackbarView: BaseUIView {

    // MARK: - Properties

    var buttonAction: (() -> Void)?

    // MARK: - UI Properties

    private let messageLabel = UILabel()
    private let actionButton = UIButton(type: .system)

    // MARK: - Initializer

    init(message: String, buttonTitle: String) {
        super.init(frame: .zero)
        messageLabel.text = message
        actionButton.setTitle(buttonTitle, for: .normal)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - UI Setting

    override func setStyle() {
        backgroundColor = .grey_900
        layer.cornerRadius = .r12
        clipsToBounds = true

        messageLabel.do {
            $0.font = .label_r_12
            $0.textColor = .staticWhite
            $0.lineBreakMode = .byTruncatingTail
            $0.numberOfLines = 1
        }

        actionButton.do {
            $0.titleLabel?.font = .label_sb_14
            $0.setTitleColor(.status_error, for: .normal)
            $0.setContentCompressionResistancePriority(.required, for: .horizontal)
        }
    }

    override func setUI() {
        addSubviews(messageLabel, actionButton)

        actionButton.addAction(UIAction { [weak self] _ in
            self?.buttonAction?()
        }, for: .touchUpInside)
    }

    override func setLayout() {
        snp.makeConstraints {
            $0.width.equalTo(343)
            $0.height.equalTo(48)
        }

        messageLabel.snp.makeConstraints {
            $0.leading.equalToSuperview().inset(CGFloat.s16)
            $0.centerY.equalToSuperview()
            $0.trailing.lessThanOrEqualTo(actionButton.snp.leading).offset(-CGFloat.s12)
        }

        actionButton.snp.makeConstraints {
            $0.trailing.equalToSuperview().inset(CGFloat.s6)
            $0.centerY.equalToSuperview()
        }
    }
}
