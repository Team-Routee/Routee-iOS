//
//  WorkoutRecordThumbnail.swift
//  Routee-iOS
//
//  Created by 김세령 on 7/6/26.
//

import UIKit

import SnapKit
import Then

final class WorkoutRecordThumbnail: BaseUIView {
    
    // MARK: - UI Properties
    
    private let backgroundContainerView = UIView()
    private let backgroundPhotoView = UIImageView()
    private let borderOverlayView = UIView()
    private let firstPhotoView = UIImageView()
    private let secondPhotoView = UIImageView()
    private let thirdPhotoView = UIImageView()
    private let editButton = UIButton()

    // MARK: - UI Settings
    
    override func setStyle() {
        backgroundContainerView.do {
            $0.backgroundColor = .dimSecondary
            $0.layer.cornerRadius = 20
            $0.clipsToBounds = true
        }
        
        backgroundPhotoView.do {
            $0.image = UIImage(named: "img_location5")
            $0.contentMode = .scaleAspectFill
            $0.layer.cornerRadius = 16
            $0.clipsToBounds = true
        }
        
        borderOverlayView.do {
            $0.backgroundColor = .clear
            $0.layer.borderWidth = 1
            $0.layer.borderColor = UIColor.white10.cgColor
            $0.layer.cornerRadius = 16
            $0.isUserInteractionEnabled = false
        }
        
        [firstPhotoView, secondPhotoView, thirdPhotoView].forEach {
            $0.contentMode = .scaleAspectFill
            $0.clipsToBounds = true
            $0.layer.cornerRadius = 8
            $0.backgroundColor = .clear
            $0.layer.borderWidth = 1
            $0.layer.borderColor = UIColor.staticWhite.cgColor
        }
        
        firstPhotoView.do {
            $0.image = UIImage(named: "img_selfcamera2")
            $0.transform = CGAffineTransform(rotationAngle: -0.12)
        }
        
        secondPhotoView.do {
            $0.image = UIImage(named: "img_location6")
            $0.transform = CGAffineTransform(rotationAngle: 0.05)
        }
        
        thirdPhotoView.do {
            $0.image = UIImage(named: "img_location1")
            $0.transform = CGAffineTransform(rotationAngle: 0.14)
        }
        
        editButton.do {
            $0.setImage(UIImage(named: "ic_edit_sm_fill_mint"), for: .normal)
            $0.backgroundColor = .dimSecondary
            $0.layer.cornerRadius = 12
        }
    }
    
    override func setUI() {
        addSubview(backgroundContainerView)
        
        backgroundContainerView.addSubviews(backgroundPhotoView, borderOverlayView, firstPhotoView, secondPhotoView, thirdPhotoView, editButton)
    }
    
    override func setLayout() {
        backgroundContainerView.snp.makeConstraints {
            $0.edges.equalToSuperview()
            $0.height.equalTo(192)
            $0.width.equalTo(152)
        }
        
        backgroundPhotoView.snp.makeConstraints {
            $0.center.equalTo(backgroundContainerView)
            $0.height.equalTo(180)
            $0.width.equalTo(140)
        }
        
        borderOverlayView.snp.makeConstraints {
            $0.center.equalTo(backgroundContainerView)
            $0.height.equalTo(180)
            $0.width.equalTo(140)
        }
        
        firstPhotoView.snp.makeConstraints {
            $0.top.equalTo(backgroundContainerView.snp.top).offset(96)
            $0.leading.equalTo(backgroundContainerView.snp.leading).offset(13)
            $0.height.equalTo(72)
            $0.width.equalTo(56)
        }
        
        secondPhotoView.snp.makeConstraints {
            $0.top.equalTo(backgroundContainerView.snp.top).offset(83)
            $0.leading.equalTo(backgroundContainerView.snp.leading).offset(39)
            $0.height.equalTo(72)
            $0.width.equalTo(56)
        }
        
        thirdPhotoView.snp.makeConstraints {
            $0.top.equalTo(backgroundContainerView.snp.top).offset(96)
            $0.trailing.equalTo(backgroundContainerView.snp.trailing).offset(-12)
            $0.height.equalTo(72)
            $0.width.equalTo(56)
        }
        
        editButton.snp.makeConstraints {
            $0.size.equalTo(24)
            $0.top.equalToSuperview().inset(16)
            $0.trailing.equalToSuperview().inset(16)
        }
    }
}
