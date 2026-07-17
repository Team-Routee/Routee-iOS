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
    private let chevronButton = UIButton()

    // MARK: - Initializer

    init(title: String) {
        super.init(frame: .zero)

        titleLabel.text = title
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
            $0.font = .label_m_14
        }

        chevronButton.do {
            $0.setImage(UIImage(named: "ic_chevron_right_sm_white"), for: .normal)
            $0.setImage(UIImage(named: "ic_chevron_right_sm_grey"), for: .highlighted)
            $0.imageView?.contentMode = .scaleAspectFit
            $0.isUserInteractionEnabled = false
        }
    }

    private func setUI() {
        addSubviews(titleLabel, chevronButton)
    }

    private func setLayout() {
        titleLabel.snp.makeConstraints {
            $0.leading.centerY.equalToSuperview()
            $0.verticalEdges.equalToSuperview()
        }

        chevronButton.snp.makeConstraints {
            $0.trailing.centerY.equalToSuperview()
            $0.size.equalTo(24)
        }
    }

    // MARK: - Public Methods

    func setAction(target: Any?, action: Selector) {
        titleLabel.isUserInteractionEnabled = true
        titleLabel.addGestureRecognizer(
            UITapGestureRecognizer(target: target, action: action)
        )

        chevronButton.isUserInteractionEnabled = true
        chevronButton.addTarget(target, action: action, for: .touchUpInside)
    }
}
