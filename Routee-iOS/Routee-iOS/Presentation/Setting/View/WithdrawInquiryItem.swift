//
//  WithdrawInquiryItem.swift
//  Routee-iOS
//
//  Created by 초긍정행운의포춘쿠키 on 8/26/26.
//
import UIKit

import SnapKit
import Then

final class WithdrawInquiryItem: UIControl {

    // MARK: - UI Properties

    private let iconImageView = UIImageView()
    private let titleLabel = UILabel()
    private let chevronImageView = UIImageView()

    // MARK: - Initializer

    init(iconImage: ImageResource, title: String) {
        super.init(frame: .zero)

        iconImageView.image = UIImage(resource: iconImage)
        titleLabel.text = title

        setStyle()
        setUI()
        setLayout()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - UI Setting

    private func setStyle() {
        iconImageView.contentMode = .scaleAspectFit

        titleLabel.do {
            $0.textColor = .staticWhite
            $0.font = .label_m_14
        }

        chevronImageView.do {
            $0.image = UIImage(resource: .icChevronRightSmWhite)
            $0.contentMode = .scaleAspectFit
        }
    }

    private func setUI() {
        addSubviews(iconImageView, titleLabel, chevronImageView)
    }

    private func setLayout() {
        iconImageView.snp.makeConstraints {
            $0.leading.centerY.equalToSuperview()
            $0.size.equalTo(24)
        }

        titleLabel.snp.makeConstraints {
            $0.leading.equalTo(iconImageView.snp.trailing).offset(8)
            $0.centerY.equalToSuperview()
        }

        chevronImageView.snp.makeConstraints {
            $0.trailing.centerY.equalToSuperview()
            $0.size.equalTo(24)
        }
    }
}
