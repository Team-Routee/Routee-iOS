//
//  WorkoutRecordThumbnail.swift
//  Routee-iOS
//
//  Created by 김세령 on 7/6/26.
//

import UIKit

import Kingfisher
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
            $0.layer.borderColor = UIColor.white_30.cgColor
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
            $0.transform = CGAffineTransform(rotationAngle: 5 * .pi / 180)
        }
        
        thirdPhotoView.do {
            $0.transform = CGAffineTransform(rotationAngle: 8 * .pi / 180)
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
            thirdPhotoView
        )
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

    func configure(imageURLs: [String]) {
        let imageURLs = Array(imageURLs.prefix(4))
        let hasImages = !imageURLs.isEmpty

        backgroundContainerView.backgroundColor = hasImages ? .white_30 : .grey900
        backgroundPhotoView.isHidden = !hasImages
        borderOverlayView.isHidden = !hasImages
        emptyIconImageView.isHidden = hasImages

        configureImageView(backgroundPhotoView, with: imageURLs.first)

        foregroundPhotoViews.enumerated().forEach { index, imageView in
            let imageIndex = index + 1
            let hasForegroundImage = imageIndex < imageURLs.count

            configureImageView(imageView, with: hasForegroundImage ? imageURLs[imageIndex] : nil)
            imageView.isHidden = !hasForegroundImage
        }
    }

    // MARK: - Private Methods

    private func configureImageView(_ imageView: UIImageView, with imageURL: String?) {
        imageView.kf.cancelDownloadTask()

        guard let imageURL,
              let url = URL(string: imageURL) else {
            imageView.image = nil
            return
        }

        imageView.kf.setImage(with: url)
    }
}
