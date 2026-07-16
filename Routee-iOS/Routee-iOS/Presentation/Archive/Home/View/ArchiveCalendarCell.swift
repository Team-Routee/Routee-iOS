//
//  CalendarCell.swift
//  Routee-iOS
//
//  Created by 초긍정행운의포춘쿠키 on 7/6/26.
//
import UIKit

import Kingfisher
import SnapKit
import Then

final class ArchiveCalendarCell: UICollectionViewCell {

    // MARK: - Properties

    static let reuseIdentifier = "CalendarCell"

    // MARK: - UI Properties

    private let backgroundImageView = UIImageView()
    private let thumbnailImageView = UIImageView()
    private let dayLabel = UILabel()
    private let badgeBackgroundImageView = UIImageView()

    // MARK: - Initializer

    override init(frame: CGRect) {
        super.init(frame: frame)

        setStyle()
        setUI()
        setLayout()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - UI Setting

    private func setStyle() {
        clipsToBounds = false
        contentView.clipsToBounds = false

        backgroundImageView.do {
            $0.image = UIImage(named: "calendar_bg")
            $0.contentMode = .scaleAspectFill
            $0.layer.cornerRadius = 12
            $0.layer.masksToBounds = true
            $0.isHidden = true
        }

        thumbnailImageView.do {
            $0.contentMode = .scaleAspectFill
            $0.layer.cornerRadius = 12
            $0.layer.masksToBounds = true
            $0.isHidden = true
        }

        dayLabel.do {
            $0.font = .label_m_14
            $0.textColor = .static_white
            $0.textAlignment = .center
        }

        badgeBackgroundImageView.do {
            $0.contentMode = .scaleAspectFit
            $0.isHidden = true
        }
    }

    private func setUI() {
        contentView.addSubviews(
            backgroundImageView,
            thumbnailImageView,
            dayLabel,
            badgeBackgroundImageView
        )
    }

    private func setLayout() {
        backgroundImageView.snp.makeConstraints {
            $0.center.equalToSuperview()
            $0.size.equalTo(38)
        }

        thumbnailImageView.snp.makeConstraints {
            $0.center.equalToSuperview()
            $0.size.equalTo(38)
        }

        dayLabel.snp.makeConstraints {
            $0.center.equalToSuperview()
        }

        badgeBackgroundImageView.snp.makeConstraints {
            $0.top.equalTo(thumbnailImageView).offset(-4)
            $0.trailing.equalTo(thumbnailImageView).offset(4)
            $0.size.equalTo(16)
        }
    }

    // MARK: - Public Methods

    func configure(with date: CalendarCellModel) {
        resetCell()

        switch date.content {
        case .empty:
            return

        case .day(let number):
            dayLabel.text = "\(number)"
        }

        switch date.recordState {
        case .none:
            return

        case .single:
            configureSingleActivity(imageUrl: date.coverImageUrl)

        case .multiple(let count):
            configureMultipleActivity(imageUrl: date.coverImageUrl)
            badgeBackgroundImageView.image = UIImage(named: "\(count)")
            badgeBackgroundImageView.isHidden = false
        }
    }

    // MARK: - Private Methods

    private func resetCell() {
        thumbnailImageView.kf.cancelDownloadTask()
        backgroundImageView.isHidden = true
        thumbnailImageView.isHidden = true
        thumbnailImageView.image = nil
        badgeBackgroundImageView.image = nil
        badgeBackgroundImageView.isHidden = true
        dayLabel.text = nil
        dayLabel.textColor = .static_white
    }

    private func configureSingleActivity(imageUrl: String?) {
        if configureThumbnailImage(imageUrl: imageUrl) {
            dayLabel.text = nil
        } else {
            backgroundImageView.image = .calendarBg
            backgroundImageView.isHidden = false
        }
    }

    private func configureMultipleActivity(imageUrl: String?) {
        if configureThumbnailImage(imageUrl: imageUrl) {
            dayLabel.text = nil
        } else {
            backgroundImageView.image = .calendarBg2
            backgroundImageView.isHidden = false
        }
    }

    private func configureThumbnailImage(imageUrl: String?) -> Bool {
        guard let imageUrl,
              let url = URL(string: imageUrl) else { return false }

        thumbnailImageView.kf.setImage(with: url)
        thumbnailImageView.isHidden = false
        return true
    }
}
