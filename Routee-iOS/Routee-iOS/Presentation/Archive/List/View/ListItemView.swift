//
//  ListItemView.swift
//  Routee-iOS
//
//  Created by Codex on 7/8/26.
//

import UIKit

import SnapKit
import Then

final class ListItemView: BaseUIView {

    private enum Metric {
        static let cardHeight: CGFloat = 66
        static let thumbnailSize: CGFloat = 48
    }

    private let thumbnailImageView = UIImageView()
    private let titleLabel = UILabel()
    private let chevronImageView = UIImageView()

    override func setStyle() {
        backgroundColor = .white_10
        layer.cornerRadius = .r16
        layer.masksToBounds = true

        thumbnailImageView.do {
            $0.contentMode = .scaleAspectFill
            $0.layer.cornerRadius = .r12
            $0.layer.masksToBounds = true
        }

        titleLabel.do {
            $0.textColor = .static_white
            $0.font = .label_sb_16
            $0.numberOfLines = 1
        }

        chevronImageView.do {
            $0.image = .icChevronRightSmWhite
            $0.contentMode = .scaleAspectFit
        }
    }

    override func setUI() {
        addSubviews(thumbnailImageView, titleLabel, chevronImageView)
    }

    override func setLayout() {
        snp.makeConstraints {
            $0.height.equalTo(Metric.cardHeight)
        }

        thumbnailImageView.snp.makeConstraints {
            $0.leading.equalToSuperview().inset(16)
            $0.centerY.equalToSuperview()
            $0.size.equalTo(Metric.thumbnailSize)
        }

        titleLabel.snp.makeConstraints {
            $0.leading.equalTo(thumbnailImageView.snp.trailing).offset(12)
            $0.centerY.equalToSuperview()
            $0.trailing.lessThanOrEqualTo(chevronImageView.snp.leading).offset(-12)
        }

        chevronImageView.snp.makeConstraints {
            $0.trailing.equalToSuperview().inset(16)
            $0.centerY.equalToSuperview()
            $0.size.equalTo(24)
        }
    }

    func configure(with model: ListItemModel) {
        titleLabel.text = model.title
        thumbnailImageView.image = UIImage(named: model.imageName ?? "routee_logo_black")
    }
}
