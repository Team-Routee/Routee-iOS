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
    
    private let normalImage: UIImage
    private let selectedImage: UIImage
    
    override var isSelected: Bool { didSet { updateAppearance() } }
    
    private let lineView = UIView()
    private let iconImageView = UIImageView()
    private let titleLabel = UILabel()
    private let stackView = UIStackView()
    
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
        
        stackView.axis = .vertical
        stackView.alignment = .center
        stackView.spacing = 2
        stackView.isUserInteractionEnabled = false
    }
    
    private func setUI() {
        addSubviews(lineView, stackView)
        stackView.addArrangedSubviews(iconImageView, titleLabel)
    }
    
    private func setLayout() {
        lineView.snp.makeConstraints {
            $0.top.leading.trailing.equalToSuperview()
            $0.height.equalTo(2)
        }
        
        stackView.snp.makeConstraints {
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
    
    private func updateAppearance() {
        backgroundColor = isSelected ? .white_10 : .clear
        lineView.isHidden = !isSelected
        iconImageView.image = isSelected ? selectedImage : normalImage
        titleLabel.font = isSelected ? .label_sb_12 : .label_m_12
        titleLabel.textColor = isSelected ? .staticWhite : .grey200
    }
}
