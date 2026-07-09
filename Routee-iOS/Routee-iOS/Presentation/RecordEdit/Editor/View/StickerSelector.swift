//
//  StickerSelector.swift
//  Routee-iOS
//
//  Created by 김세령 on 7/9/26.
//

import UIKit

import SnapKit
import Then

final class StickerSelector: BaseUIView {

    // MARK: - Properties

    enum StickerType {
        case photoTimeline
        case route
    }

    var onStickerSelected: ((StickerType) -> Void)?

    // MARK: - UI Properties

    private let backgroundView = UIView()
    private let photoTimelineButton = UIControl()
    private let routeButton = UIControl()
    private let photoTimelineIconImageView = UIImageView()
    private let photoTimelineTitleLabel = UILabel()
    private let routeIconImageView = UIImageView()
    private let routeTitleLabel = UILabel()

    // MARK: - Initializer

    override init(frame: CGRect) {
        super.init(frame: frame)

        setActions()
        selectPhotoTimeline()
    }

    required init?(coder: NSCoder) {
        fatalError()
    }

    // MARK: - UI Setting

    override func setStyle() {
        
        backgroundView.do {
            $0.backgroundColor = .dimPrimary
        }
        
        photoTimelineButton.do {
            $0.layer.cornerRadius = 8
        }
        
        routeButton.do {
            $0.layer.cornerRadius = 8
        }
        
        photoTimelineIconImageView.do {
            $0.contentMode = .scaleAspectFit
        }
        
        routeIconImageView.do {
            $0.contentMode = .scaleAspectFit
        }
        
        photoTimelineTitleLabel.do {
            $0.text = "사진 타임라인"
            $0.font = .label_m_12
        }

        routeTitleLabel.do {
            $0.text = "루트"
            $0.font = .label_m_12
        }
    }

    override func setUI() {
        addSubviews(backgroundView, photoTimelineButton, routeButton)
        
        photoTimelineButton.addSubviews(photoTimelineIconImageView, photoTimelineTitleLabel)
        
        routeButton.addSubviews(routeIconImageView, routeTitleLabel)
    }

    override func setLayout() {
        backgroundView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }

        photoTimelineButton.snp.makeConstraints {
            $0.leading.equalToSuperview().inset(16)
            $0.centerY.equalToSuperview()
            $0.height.equalTo(36)
        }

        routeButton.snp.makeConstraints {
            $0.leading.equalTo(photoTimelineButton.snp.trailing).offset(8)
            $0.centerY.equalToSuperview()
            $0.height.equalTo(36)
        }

        photoTimelineIconImageView.snp.makeConstraints {
            $0.leading.equalToSuperview().inset(12)
            $0.centerY.equalToSuperview()
            $0.size.equalTo(24)
        }

        photoTimelineTitleLabel.snp.makeConstraints {
            $0.leading.equalTo(photoTimelineIconImageView.snp.trailing).offset(6)
            $0.trailing.equalToSuperview().inset(12)
            $0.centerY.equalToSuperview()
        }

        routeIconImageView.snp.makeConstraints {
            $0.leading.equalToSuperview().inset(12)
            $0.centerY.equalToSuperview()
            $0.size.equalTo(24)
        }

        routeTitleLabel.snp.makeConstraints {
            $0.leading.equalTo(routeIconImageView.snp.trailing).offset(6)
            $0.trailing.equalToSuperview().inset(12)
            $0.centerY.equalToSuperview()
        }
    }

    // MARK: - Private Methods

    private func setActions() {
        photoTimelineButton.addTarget(self, action: #selector(photoTimelineButtonTapped), for: .touchUpInside)
        routeButton.addTarget(self, action: #selector(routeButtonTapped), for: .touchUpInside)
    }

    private func selectPhotoTimeline() {
        photoTimelineButton.backgroundColor = .white_10
        routeButton.backgroundColor = .clear

        photoTimelineIconImageView.image = .icPhotoTimelineStickerSmWhite
        routeIconImageView.image = .icRouteStickerSmGrey

        photoTimelineTitleLabel.textColor = .staticWhite
        routeTitleLabel.textColor = .grey200
    }

    private func selectRoute() {
        photoTimelineButton.backgroundColor = .clear
        routeButton.backgroundColor = .white_10

        photoTimelineIconImageView.image = .icPhotoTimelineStickerSmGrey
        routeIconImageView.image = .icRouteStickerSmWhite

        photoTimelineTitleLabel.textColor = .grey200
        routeTitleLabel.textColor = .staticWhite
    }

    // MARK: - Actions

    @objc
    private func photoTimelineButtonTapped() {
        selectPhotoTimeline()
        onStickerSelected?(.photoTimeline)
    }

    @objc
    private func routeButtonTapped() {
        selectRoute()
        onStickerSelected?(.route)
    }
}
