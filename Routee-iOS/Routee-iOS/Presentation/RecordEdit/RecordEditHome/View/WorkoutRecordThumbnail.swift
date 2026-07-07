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
    
    private let emptyIconImageView = UIImageView()
    
    private let firstPhotoView = UIImageView()
    private let secondPhotoView = UIImageView()
    private let thirdPhotoView = UIImageView()
    
    private let editButton = UIButton()
    
    private lazy var foregroundPhotoViews = [
        firstPhotoView,
        secondPhotoView,
        thirdPhotoView
    ]

    // MARK: - UI Setting
    
    override func setStyle() {
        backgroundContainerView.do {
            $0.backgroundColor = .white_30
            $0.layer.cornerRadius = 20
            $0.layer.borderWidth = 6
            $0.layer.borderColor = UIColor.grey_500.cgColor
            $0.clipsToBounds = true
        }
        
        backgroundPhotoView.do {
            $0.contentMode = .scaleAspectFill
            $0.layer.cornerRadius = 16
            $0.clipsToBounds = true
        }
    
        borderOverlayView.do {
            $0.backgroundColor = .clear
            $0.layer.borderWidth = 4
            $0.layer.borderColor = UIColor.white30.cgColor
            $0.layer.cornerRadius = 16
            $0.isUserInteractionEnabled = false
        }
        
        emptyIconImageView.do {
            $0.image = UIImage(named: "routee_symbol_grey_sm")
            $0.contentMode = .scaleAspectFit
        }
        
        foregroundPhotoViews.forEach {
            $0.contentMode = .scaleAspectFill
            $0.clipsToBounds = true
            $0.layer.cornerRadius = 8
            $0.backgroundColor = .clear
            $0.layer.borderWidth = 2
            $0.layer.borderColor = UIColor.staticWhite.cgColor
        }
        
        firstPhotoView.do {
            $0.transform = CGAffineTransform(rotationAngle: -8 * .pi / 180)
        }
        
        secondPhotoView.do {
            $0.transform = CGAffineTransform(rotationAngle: 2 * .pi / 180)
        }
        
        thirdPhotoView.do {
            $0.transform = CGAffineTransform(rotationAngle: 4 * .pi / 180)
        }
        
        editButton.do {
            $0.setImage(UIImage(named: "ic_edit_sm_fill_mint"), for: .normal)
            $0.backgroundColor = .dimSecondary
            $0.layer.cornerRadius = 12
        }
    }
    
    override func setUI() {
        addSubview(backgroundContainerView)
        
        backgroundContainerView.addSubviews(
            backgroundPhotoView,
            borderOverlayView,
            emptyIconImageView,
            firstPhotoView,
            secondPhotoView,
            thirdPhotoView,
            editButton
        )
        
        configure(imageNames: [])
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
        
        emptyIconImageView.snp.makeConstraints {
            $0.center.equalTo(backgroundContainerView)
            $0.width.equalTo(75)
            $0.height.equalTo(39)
        }
        
        firstPhotoView.snp.makeConstraints {
            $0.bottom.equalTo(backgroundContainerView.snp.bottom).offset(-20)
            $0.leading.equalTo(backgroundContainerView.snp.leading).offset(18)
            $0.height.equalTo(72)
            $0.width.equalTo(56)
        }
        
        secondPhotoView.snp.makeConstraints {
            $0.bottom.equalTo(backgroundContainerView.snp.bottom).offset(-28)
            $0.leading.equalTo(backgroundContainerView.snp.leading).offset(63)
            $0.height.equalTo(72)
            $0.width.equalTo(56)
        }
        
        thirdPhotoView.snp.makeConstraints {
            $0.bottom.equalTo(backgroundContainerView.snp.bottom).offset(-18)
            $0.trailing.equalTo(backgroundContainerView.snp.trailing).offset(-15)
            $0.height.equalTo(72)
            $0.width.equalTo(56)
        }
        
        editButton.snp.makeConstraints {
            $0.size.equalTo(36)
            $0.top.equalToSuperview().inset(16)
            $0.trailing.equalToSuperview().inset(16)
        }
    }
    
    // MARK: - Public Methods

    func configure(imageNames: [String]) {
        let imageNames = Array(imageNames.prefix(4))
        let hasImages = !imageNames.isEmpty
        
        backgroundContainerView.backgroundColor = hasImages ? .white_30 : .grey900
        backgroundPhotoView.image = imageNames.first.flatMap { UIImage(named: $0) }
        backgroundPhotoView.isHidden = !hasImages
        borderOverlayView.isHidden = !hasImages
        emptyIconImageView.isHidden = hasImages
        
        foregroundPhotoViews.enumerated().forEach { index, imageView in
            let imageIndex = index + 1
            let hasForegroundImage = imageIndex < imageNames.count
            
            imageView.image = hasForegroundImage ? UIImage(named: imageNames[imageIndex]) : nil
            imageView.isHidden = !hasForegroundImage
        }
    }
}
