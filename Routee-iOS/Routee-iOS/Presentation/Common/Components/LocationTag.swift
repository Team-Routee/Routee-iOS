//
//  LocationTag.swift
//  Routee-iOS
//
//  Created by 초긍정행운의포춘쿠키 on 7/11/26.
//

import UIKit

import SnapKit
import Then

final class LocationTag: BaseUIView {
    
    // MARK: - UI Properties
    
    private let locationIcon = UIImageView()
    private let locationLabel = UILabel()
    
    // MARK: - Properties
    
    private var title: String
    
    // MARK: - Initializer
    
    init(title: String) {
        self.title = title
        super.init(frame: .zero)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - UI Setting
    
    override func setStyle() {
        backgroundColor = .dimSecondary
        layer.cornerRadius = .r8
        layer.masksToBounds = true
        
        locationIcon.do {
            $0.image = .icLocationInfoSmGradient
            $0.contentMode = .scaleAspectFit
        }
        
        locationLabel.do {
            $0.font = .label_sb_14
            $0.textColor = .mint100
            $0.text = title
            $0.numberOfLines = 1
        }
    }

    override func setUI() {
        addSubviews(locationIcon, locationLabel)
    }
    
    override func setLayout() {
        snp.makeConstraints {
            $0.height.equalTo(28)
        }
        
        locationIcon.snp.makeConstraints {
            $0.leading.equalToSuperview().inset(4)
            $0.centerY.equalToSuperview()
            $0.size.equalTo(24)
        }
        
        locationLabel.snp.makeConstraints {
            $0.leading.equalTo(locationIcon.snp.trailing).offset(1)
            $0.centerY.equalToSuperview()
            $0.trailing.equalToSuperview().inset(8)
        }
    }
}
