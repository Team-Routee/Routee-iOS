//
//  RecordEditTabBarItem.swift
//  Routee-iOS
//
//  Created by 김세령 on 7/8/26.
//

import UIKit

import SnapKit
import Then

final class RecordEditTabBarItem: UIControl {

    // MARK: - Properties

    private let normalImage: UIImage
    private let selectedImage: UIImage

    override var isSelected: Bool { didSet { updateAppearance() } }

    // MARK: - UI Properties

    private let lineView = UIView()
    private let iconImageView = UIImageView()
    private let titleLabel = UILabel()
    private let buttonStackView = UIStackView()

    // MARK: - Initializer

    init(title: String, normalImage: UIImage, selectedImage: UIImage) {
        self.normalImage = normalImage
        self.selectedImage = selectedImage
        super.init(frame: .zero)
        
        titleLabel.text = title
        setStyle()
        setUI()
        setLayout()
        updateAppearance()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - UI Setting

    private func setStyle() {
        layer.cornerRadius = 0

        lineView.backgroundColor = .white_10
        lineView.isHidden = true
        iconImageView.contentMode = .scaleAspectFit

        titleLabel.do {
            $0.font = .label_m_12
            $0.numberOfLines = 1
            $0.textAlignment = .center
            $0.setContentCompressionResistancePriority(.required, for: .horizontal)
        }

        buttonStackView.do {
            $0.axis = .vertical
            $0.alignment = .center
            $0.spacing = 2
            $0.isUserInteractionEnabled = false
        }
    }
    
    private func setUI() {
        addSubviews(lineView, buttonStackView)
        buttonStackView.addArrangedSubviews(iconImageView, titleLabel)
    }

    private func setLayout() {
        lineView.snp.makeConstraints {
            $0.top.horizontalEdges.equalToSuperview()
            $0.height.equalTo(2)
        }

        buttonStackView.snp.makeConstraints {
            $0.top.bottom.equalToSuperview().inset(14)
            $0.centerX.equalToSuperview()
        }

        iconImageView.snp.makeConstraints {
            $0.size.equalTo(24)
        }

        titleLabel.snp.makeConstraints {
            $0.height.equalTo(17)
        }
    }

    // MARK: - Private Methods

    private func updateAppearance() {
        backgroundColor = isSelected ? .white_10 : .clear
        lineView.isHidden = !isSelected
        iconImageView.image = isSelected ? selectedImage : normalImage
        titleLabel.font = isSelected ? .label_sb_12 : .label_m_12
        titleLabel.textColor = isSelected ? .staticWhite : .grey200
    }
}
