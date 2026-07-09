//
//  Profile.swift
//  Routee-iOS
//
//  Created by 초긍정행운의포춘쿠키 on 7/7/26.
//

import UIKit

import SnapKit
import Then

final class Profile: BaseUIView {
    
    // MARK: - Properties

    private var userName = ""
    private var streakNumber = ""
    private var pointNumber = ""
    
    // MARK: - Initializer

    override init(frame: CGRect) {
        super.init(frame: frame)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - UI Properties
    
    private let profileImageView = UIImageView()
    private let profileInfoView = UIView()
    private let nameLabel = UILabel()
    private let streakImage = UIImageView()
    private let streakLabel = UILabel()
    private let pointView = UIView()
    private let pointImage = UIImageView()
    private let pointLabel = UILabel()
    
    // MARK: - UI Setting
    
    override func setStyle() {
        profileImageView.do {
            $0.image = .profileImgDefault
            $0.contentMode = .scaleAspectFill
            $0.layer.cornerRadius = 37
            $0.clipsToBounds = true
        }
        
        profileInfoView.do {
            $0.backgroundColor = .clear
        }
        
        nameLabel.do {
            $0.text = userName
            $0.textColor = .static_white
            $0.font = .label_sb_18
        }
        
        streakImage.do {
            $0.image = .icFireSmGradient
            $0.contentMode = .scaleAspectFit
        }
        
        streakLabel.do {
            $0.text = "\(streakNumber)일 연속"
            $0.textColor = .mint_300
            $0.font = .label_m_14
        }
        
        pointView.do {
            $0.backgroundColor = .surfaceTinted
            $0.layer.cornerRadius = 14
            $0.layer.borderWidth = 1
            $0.layer.borderColor = UIColor.mint_700.cgColor
        }
        
        pointImage.do {
            $0.image = .icMountainSmGradient
            $0.contentMode = .scaleAspectFit
        }
        
        pointLabel.do {
            $0.text = "\(pointNumber)"
            $0.textColor = .staticWhite
            $0.font = .label_r_12
        }
    }
    
    override func setUI() {
        addSubviews(profileImageView, profileInfoView, pointView)
        profileInfoView.addSubviews(nameLabel, streakImage, streakLabel)
        pointView.addSubviews(pointImage, pointLabel)
    }
    
    override func setLayout() {
        profileImageView.snp.makeConstraints {
            $0.top.leading.bottom.equalToSuperview()
            $0.size.equalTo(74)
        }
        profileInfoView.snp.makeConstraints {
            $0.top.equalTo(profileImageView.snp.top)
            $0.leading.equalTo(profileImageView.snp.trailing).offset(14)
        }
        nameLabel.snp.makeConstraints {
            $0.top.leading.equalToSuperview().inset(10)
            $0.width.equalTo(136)
            $0.height.equalTo(25)
        }
        
        streakImage.snp.makeConstraints {
            $0.top.equalTo(nameLabel.snp.bottom).offset(10)
            $0.leading.equalTo(nameLabel)
            $0.size.equalTo(16)
        }
        
        streakLabel.snp.makeConstraints {
            $0.centerY.equalTo(streakImage.snp.centerY)
            $0.leading.equalTo(streakImage.snp.trailing).offset(4)
            $0.height.equalTo(20)
        }
        
        pointLabel.snp.makeConstraints {
            $0.trailing.equalTo(pointView.snp.trailing).inset(12)
            $0.centerY.equalToSuperview()
            $0.height.equalTo(17)
        }
        
        pointImage.snp.makeConstraints {
            $0.trailing.equalTo(pointLabel.snp.leading).offset(-2)
            $0.centerY.equalToSuperview()
            $0.size.equalTo(24)
        }
        pointView.snp.makeConstraints {
            $0.top.trailing.equalToSuperview()
            $0.leading.equalTo(pointImage.snp.leading).offset(-8)
            $0.height.equalTo(28)
        }
    }
    // MARK: - public Methods
    func configure(with model: ProfileModel) {
        userName = model.userName
        streakNumber = "\(model.streakNumber)"
        pointNumber = "\(model.pointNumber)"

        profileImageView.image = UIImage(named: model.profileImageName) ?? .profileImgDefault
        nameLabel.text = userName
        streakLabel.text = "\(streakNumber)일째 루티와 함께하는 중"
        pointLabel.text = pointNumber
    }
}
