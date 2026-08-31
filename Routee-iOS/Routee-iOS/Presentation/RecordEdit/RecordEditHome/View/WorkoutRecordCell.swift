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
    var onThumbnailTap: (() -> Void)?
    var onTitleEditingDidEnd: ((String) -> Void)?

    private let formatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy.MM.dd."
        return formatter
    }()

    // MARK: - UI Properties
    
    private let workoutRecordThumbnail = WorkoutRecordThumbnail()
    private let workoutTitleEditor = WorkoutTitleEditor()
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
        
        workoutTitleEditor.endEditingIfNeeded()
        onThumbnailTap = nil
        onTitleEditingDidEnd = nil
        workoutRecordThumbnail.configure(imageNames: [])
        workoutRecordThumbnail.configure(imageURLs: [])
    }
    
    // MARK: - UI Setting
    
    private func setStyle() {
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
            workoutTitleEditor,
            dateLabel
        )

        setActions()
    }
    
    private func setLayout() {
        workoutRecordThumbnail.snp.makeConstraints {
            $0.top.horizontalEdges.equalTo(contentView)
            $0.height.equalTo(192)
        }
        
        workoutTitleEditor.snp.makeConstraints {
            $0.top.equalTo(workoutRecordThumbnail.snp.bottom).offset(CGFloat.s16)
            $0.horizontalEdges.equalTo(contentView)
        }
        
        dateLabel.snp.makeConstraints {
            $0.top.equalTo(workoutTitleEditor.snp.bottom).offset(2)
            $0.horizontalEdges.equalTo(contentView)
            $0.bottom.lessThanOrEqualTo(contentView)
        }
    }

    // MARK: - Public Methods

    func configure(with workout: WorkoutRecordModel) {
        workoutTitleEditor.configure(title: workout.title)
        dateLabel.text = formatter.string(from: workout.date)
        workoutRecordThumbnail.configure(imageNames: workout.imageNames)
    }

    func configure(with workout: WorkoutListModel) {
        workoutTitleEditor.configure(title: workout.title)
        dateLabel.text = workout.activityDate.replacingOccurrences(of: "-", with: ".") + "."
        workoutRecordThumbnail.configure(imageURLs: workout.timelineImageUrls)
    }

    // MARK: - Private Methods

    private func setActions() {
        let thumbnailTapGesture = UITapGestureRecognizer(
            target: self,
            action: #selector(didTapThumbnail)
        )
        workoutRecordThumbnail.addGestureRecognizer(thumbnailTapGesture)

        workoutTitleEditor.titleEditingDidEnd = { [weak self] title in
            self?.onTitleEditingDidEnd?(title)
        }
    }

    // MARK: - Actions

    @objc
    private func didTapThumbnail() {
        onThumbnailTap?()
    }
}
