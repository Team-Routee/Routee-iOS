//
//  SettingItemView.swift
//  Routee-iOS
//
//  Created by 김세령 on 7/13/26.
//

import UIKit

import SnapKit
import Then

final class SettingItemView: UIView {

    // MARK: - UI Properties

    private let titleLabel = UILabel()
    private let trailingLabel = UILabel()
    private let chevronButton = UIButton()

    // MARK: - Initializer

    init(title: String, trailingText: String? = nil) {
        super.init(frame: .zero)

        titleLabel.text = title
        trailingLabel.text = trailingText
        setStyle()
        setUI()
        setLayout()
    }

    required init?(coder: NSCoder) {
        fatalError()
    }

    // MARK: - UI Setting

    private func setStyle() {
        titleLabel.do {
            $0.textColor = .staticWhite
            $0.font = .label_m_16
        }

        trailingLabel.do {
            $0.textColor = .staticWhite
            $0.font = .label_r_14
            $0.isHidden = trailingLabel.text == nil
        }

        chevronButton.do {
            $0.setImage(UIImage(named: "ic_chevron_right_sm_white"), for: .normal)
            $0.setImage(UIImage(named: "ic_chevron_right_sm_grey"), for: .highlighted)
            $0.imageView?.contentMode = .scaleAspectFit
            $0.isUserInteractionEnabled = false
        }
    }

    private func setUI() {
        addSubviews(titleLabel, trailingLabel, chevronButton)
    }

    private func setLayout() {
        snp.makeConstraints {
            $0.width.equalTo(311)
            $0.height.equalTo(40)
        }

        titleLabel.snp.makeConstraints {
            $0.leading.centerY.equalToSuperview()
        }

        trailingLabel.snp.makeConstraints {
            $0.centerY.equalToSuperview()
            $0.trailing.equalTo(chevronButton.snp.leading).offset(-2)
        }

        chevronButton.snp.makeConstraints {
            $0.trailing.centerY.equalToSuperview()
            $0.size.equalTo(24)
        }
    }

    // MARK: - Public Methods

    func setAction(target: Any?, action: Selector) {
        isUserInteractionEnabled = true
        addGestureRecognizer(
            UITapGestureRecognizer(target: target, action: action)
        )

        chevronButton.isUserInteractionEnabled = true
        chevronButton.addTarget(target, action: action, for: .touchUpInside)
    }
}
