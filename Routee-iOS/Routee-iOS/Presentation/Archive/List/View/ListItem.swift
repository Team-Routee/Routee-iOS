//
//  ListItem.swift
//  Routee-iOS
//

import UIKit

import SnapKit
import Then

final class ListItem: BaseUIView {

    // MARK: - UI Properties
    
    private let thumbnailImageView = UIImageView()
    private let recordListLabel = UILabel()
    private let chevronIcon = UIImageView()
    
    // MARK: - UI Setting
    
    override func setStyle() {
        backgroundColor = .white_10
        layer.cornerRadius = .r12
        layer.masksToBounds = true

        thumbnailImageView.do {
            $0.contentMode = .scaleAspectFill
            $0.layer.cornerRadius = .r12
            $0.clipsToBounds = true
        }

        recordListLabel.do {
            $0.textColor = .static_white
            $0.font = .label_m_14
            $0.numberOfLines = 1
        }

        chevronIcon.do {
            $0.image = .icChevronRightSmGrey
            $0.contentMode = .scaleAspectFit
        }
    }

    override func setUI() {
        addSubviews(thumbnailImageView, recordListLabel, chevronIcon)
    }

    override func setLayout() {
        snp.makeConstraints {
            $0.height.equalTo(66)
        }

        thumbnailImageView.snp.makeConstraints {
            $0.leading.equalToSuperview().inset(12)
            $0.centerY.equalToSuperview()
            $0.size.equalTo(42)
        }

        recordListLabel.snp.makeConstraints {
            $0.leading.equalTo(thumbnailImageView.snp.trailing).offset(12)
            $0.centerY.equalToSuperview()
            $0.trailing.lessThanOrEqualTo(chevronIcon.snp.leading).offset(-12)
        }

        chevronIcon.snp.makeConstraints {
            $0.trailing.equalToSuperview().inset(12)
            $0.centerY.equalToSuperview()
            $0.size.equalTo(24)
        }
    }
    
    // MARK: - Public Methods
    
    func configure(with model: ListItemModel) {
        recordListLabel.text = model.title
        thumbnailImageView.image = thumbnailImage(thumbnailUrl: model.thumbnailUrl)
    }

    // MARK: - Private Methods
    
    private func thumbnailImage(thumbnailUrl: String?) -> UIImage {
        guard let thumbnailUrl else {
            return .routeeLogoBlack
        }

        return UIImage(named: thumbnailUrl) ?? .routeeLogoBlack
    }
}
