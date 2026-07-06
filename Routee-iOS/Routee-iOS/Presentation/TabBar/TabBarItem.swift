//
//  TabBarItem.swift
//  Routee-iOS
//
//  Created by 초긍정행운의포춘쿠키 on 7/5/26.
//

import UIKit

import SnapKit
import Then

final class TabBarItem: UIControl {
    
    // MARK: - Properties
    
    private var normalImage: UIImage?
    private var selectedImage: UIImage?
    
    override var isSelected: Bool {
        didSet { updateAppearance() }
    }
    
    // MARK: - UI Properties
    
    private let imageView = UIImageView()
    private let titleLabel = UILabel()
    
    // MARK: - Initialize
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        setStyle()
        setUI()
        setLayout()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Private
    
    private func setStyle() {
        imageView.do {
            $0.contentMode = .scaleAspectFit
        }
        
        titleLabel.do {
            $0.font = .label_m_12
            $0.textAlignment = .center
        }
    }
    
    private func setUI() {
        addSubviews(imageView, titleLabel)
    }
    
    private func setLayout() {
        imageView.snp.makeConstraints {
            $0.top.equalToSuperview()
            $0.centerX.equalToSuperview()
            $0.width.height.equalTo(24)
        }
        
        titleLabel.snp.makeConstraints {
            $0.top.equalTo(imageView.snp.bottom)
            $0.centerX.equalToSuperview()
            $0.bottom.equalToSuperview()
            $0.height.equalTo(17)
        }
    }
}
