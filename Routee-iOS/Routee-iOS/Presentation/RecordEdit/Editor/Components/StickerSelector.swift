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

    enum StickerType: Hashable {
        case record
        case photoTimeline
        case route
    }

    var onStickerSelected: ((StickerType) -> Void)?

    // MARK: - UI Properties

    private let backgroundView = UIView()
    private let recordButton = UIControl()
    private let photoTimelineButton = UIControl()
    private let routeButton = UIControl()
    private let recordIconImageView = UIImageView()
    private let recordTitleLabel = UILabel()
    private let photoTimelineIconImageView = UIImageView()
    private let photoTimelineTitleLabel = UILabel()
    private let routeIconImageView = UIImageView()
    private let routeTitleLabel = UILabel()

    // MARK: - Initializer

    override init(frame: CGRect) {
        super.init(frame: frame)

        setActions()
        deselectAll()
    }

    required init?(coder: NSCoder) {
        fatalError()
    }

    // MARK: - UI Setting

    override func setStyle() {
        
        backgroundView.do {
            $0.backgroundColor = .dimPrimary
        }
        
        [recordButton, photoTimelineButton, routeButton].forEach {
            $0.layer.cornerRadius = 8
        }

        [recordIconImageView, photoTimelineIconImageView, routeIconImageView].forEach {
            $0.contentMode = .scaleAspectFit
        }

        recordTitleLabel.do {
            $0.text = "기록"
            $0.font = .label_m_12
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
        addSubviews(backgroundView, recordButton, photoTimelineButton, routeButton)

        recordButton.addSubviews(recordIconImageView, recordTitleLabel)

        photoTimelineButton.addSubviews(photoTimelineIconImageView, photoTimelineTitleLabel)

        routeButton.addSubviews(routeIconImageView, routeTitleLabel)
    }

    override func setLayout() {
        backgroundView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }

        recordButton.snp.makeConstraints {
            $0.leading.equalToSuperview().inset(16)
            $0.centerY.equalToSuperview()
            $0.height.equalTo(36)
        }

        photoTimelineButton.snp.makeConstraints {
            $0.leading.equalTo(recordButton.snp.trailing).offset(8)
            $0.centerY.equalToSuperview()
            $0.height.equalTo(36)
        }

        routeButton.snp.makeConstraints {
            $0.leading.equalTo(photoTimelineButton.snp.trailing).offset(8)
            $0.centerY.equalToSuperview()
            $0.height.equalTo(36)
        }

        recordIconImageView.snp.makeConstraints {
            $0.leading.equalToSuperview().inset(12)
            $0.centerY.equalToSuperview()
            $0.size.equalTo(24)
        }

        recordTitleLabel.snp.makeConstraints {
            $0.leading.equalTo(recordIconImageView.snp.trailing).offset(6)
            $0.trailing.equalToSuperview().inset(12)
            $0.centerY.equalToSuperview()
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

    // MARK: - Public Methods

    func deselectAll() {
        recordButton.backgroundColor = .clear
        photoTimelineButton.backgroundColor = .clear
        routeButton.backgroundColor = .clear

        recordIconImageView.image = .icWorkoutRecordSmGrey
        photoTimelineIconImageView.image = .icPhotoTimelineStickerSmGrey
        routeIconImageView.image = .icRouteStickerSmGrey

        recordTitleLabel.textColor = .grey200
        photoTimelineTitleLabel.textColor = .grey200
        routeTitleLabel.textColor = .grey200
    }

    // MARK: - Private Methods

    private func setActions() {
        recordButton.addTarget(self, action: #selector(recordButtonTapped), for: .touchUpInside)
        photoTimelineButton.addTarget(self, action: #selector(photoTimelineButtonTapped), for: .touchUpInside)
        routeButton.addTarget(self, action: #selector(routeButtonTapped), for: .touchUpInside)
    }

    private func selectRecord() {
        recordButton.backgroundColor = .white_10
        photoTimelineButton.backgroundColor = .clear
        routeButton.backgroundColor = .clear

        recordIconImageView.image = .icWorkoutRecordSmWhite
        photoTimelineIconImageView.image = .icPhotoTimelineStickerSmGrey
        routeIconImageView.image = .icRouteStickerSmGrey

        recordTitleLabel.textColor = .staticWhite
        photoTimelineTitleLabel.textColor = .grey200
        routeTitleLabel.textColor = .grey200
    }

    private func selectPhotoTimeline() {
        recordButton.backgroundColor = .clear
        photoTimelineButton.backgroundColor = .white_10
        routeButton.backgroundColor = .clear

        recordIconImageView.image = .icWorkoutRecordSmGrey
        photoTimelineIconImageView.image = .icPhotoTimelineStickerSmWhite
        routeIconImageView.image = .icRouteStickerSmGrey

        recordTitleLabel.textColor = .grey200
        photoTimelineTitleLabel.textColor = .staticWhite
        routeTitleLabel.textColor = .grey200
    }

    private func selectRoute() {
        recordButton.backgroundColor = .clear
        photoTimelineButton.backgroundColor = .clear
        routeButton.backgroundColor = .white_10

        recordIconImageView.image = .icWorkoutRecordSmGrey
        photoTimelineIconImageView.image = .icPhotoTimelineStickerSmGrey
        routeIconImageView.image = .icRouteStickerSmWhite

        recordTitleLabel.textColor = .grey200
        photoTimelineTitleLabel.textColor = .grey200
        routeTitleLabel.textColor = .staticWhite
    }

    // MARK: - Actions

    @objc
    private func recordButtonTapped() {
        selectRecord()
        onStickerSelected?(.record)
    }

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
