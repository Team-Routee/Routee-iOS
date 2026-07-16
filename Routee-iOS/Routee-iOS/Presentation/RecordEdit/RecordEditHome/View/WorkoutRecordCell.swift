//
//  WorkoutRecordCell.swift
//  Routee-iOS
//
//  Created by 김세령 on 7/6/26.
//

import UIKit

import SnapKit
import Then

final class WorkoutRecordCell: UICollectionViewCell {
    
    // MARK: - Properties
    
    static let identifier = "WorkoutRecordCell"
    var editButtonAction: (() -> Void)?
    
    private let formatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy.MM.dd."
        return formatter
    }()

    // MARK: - UI Properties
    
    private let workoutRecordThumbnail = WorkoutRecordThumbnail()
    private let titleLabel = UILabel()
    private let dateLabel = UILabel()
    
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
    
    // MARK: - Life Cycle
    
    override func prepareForReuse() {
        super.prepareForReuse()
        
        editButtonAction = nil
        workoutRecordThumbnail.configure(imageNames: [])
        workoutRecordThumbnail.configure(imageURLs: [])
    }
    
    // MARK: - UI Setting
    
    private func setStyle() {
        titleLabel.do {
            $0.text = "숭실대 동기모임 2탄"
            $0.font = .body_sb_14
            $0.textColor = .staticWhite
            $0.textAlignment = .center
        }
        
        dateLabel.do {
            $0.text = "2026.03.23."
            $0.font = .label_m_12
            $0.textColor = .white60
            $0.textAlignment = .center
        }
    }
    
    private func setUI() {
        contentView.addSubviews(
            workoutRecordThumbnail,
            titleLabel,
            dateLabel
        )
    }
    
    private func setLayout() {
        workoutRecordThumbnail.snp.makeConstraints {
            $0.top.leading.trailing.equalTo(contentView)
            $0.height.equalTo(192)
        }
        
        titleLabel.snp.makeConstraints {
            $0.top.equalTo(workoutRecordThumbnail.snp.bottom).offset(12)
            $0.leading.trailing.equalTo(contentView)
        }
        
        dateLabel.snp.makeConstraints {
            $0.top.equalTo(titleLabel.snp.bottom).offset(2)
            $0.leading.trailing.equalTo(contentView)
            $0.bottom.lessThanOrEqualTo(contentView)
        }
    }

    // MARK: - Public Methods

    func configure(with workout: WorkoutRecordModel) {
        titleLabel.text = workout.title
        dateLabel.text = formatter.string(from: workout.date)
        workoutRecordThumbnail.configure(imageNames: workout.imageNames)
        workoutRecordThumbnail.editButtonAction = { [weak self] in
            self?.editButtonAction?()
        }
    }

    func configure(with workout: WorkoutListModel) {
        titleLabel.text = workout.title
        dateLabel.text = workout.activityDate.replacingOccurrences(of: "-", with: ".") + "."
        workoutRecordThumbnail.configure(imageURLs: workout.timelineImageUrls)
        workoutRecordThumbnail.editButtonAction = { [weak self] in
            self?.editButtonAction?()
        }
    }
}
