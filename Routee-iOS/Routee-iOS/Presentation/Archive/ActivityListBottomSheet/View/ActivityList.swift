//
//  ActivityList.swift
//  Routee-iOS
//

import UIKit

import Kingfisher
import SnapKit
import Then

final class ActivityList: BaseUIView {

    // MARK: - UI Properties
    
    private let thumbnailImageView = UIImageView()
    private let titleLabel = UILabel()
    private let chevronIcon = UIButton(type: .custom)
    private lazy var tapGestureRecognizer = UITapGestureRecognizer(
        target: self,
        action: #selector(activityListDidTap)
    )

    // MARK: - Properties

    var onChevronTap: (() -> Void)?
    
    // MARK: - UI Setting
    
    override func setStyle() {
        backgroundColor = .white10
        layer.cornerRadius = .r12
        layer.masksToBounds = true
        isUserInteractionEnabled = true
        addGestureRecognizer(tapGestureRecognizer)

        thumbnailImageView.do {
            $0.contentMode = .scaleAspectFill
            $0.layer.cornerRadius = .r12
            $0.clipsToBounds = true
        }

        titleLabel.do {
            $0.textColor = .static_white
            $0.font = .label_m_14
            $0.numberOfLines = 1
        }

        chevronIcon.do {
            $0.setImage(.icChevronRightSmWhite, for: .normal)
            $0.setImage(.icChevronRightSmWhite, for: .highlighted)
            $0.isUserInteractionEnabled = false
        }
    }

    override func setUI() {
        addSubviews(thumbnailImageView, titleLabel, chevronIcon)
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

        titleLabel.snp.makeConstraints {
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
    
    func configure(with viewModel: ActivityListRowViewModel) {
        titleLabel.text = viewModel.title
        configureThumbnailImage(with: viewModel.thumbnailURL)
    }

    // MARK: - Private Methods
    
    private func configureThumbnailImage(with url: URL?) {
        guard let url else {
            thumbnailImageView.image = .routeeLogoBlack
            return
        }

        thumbnailImageView.kf.setImage(
            with: url, placeholder: UIImage.routeeLogoBlack
        )
    }

    @objc
    private func activityListDidTap() {
        onChevronTap?()
    }
}
