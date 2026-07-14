//
//  Calendar.swift
//  Routee-iOS
//
//  Created by 초긍정행운의포춘쿠키 on 7/8/26.
//

import UIKit

import SnapKit
import Then

struct CalendarCellModel {

    enum Content {
        case empty
        case day(Int)
    }

    enum RecordState {
        case none
        case single
        case multiple(Int)
    }

    let content: Content
    let recordState: RecordState
    let coverImageName: String?
    let activityDate: String?
}

extension CalendarCellModel.RecordState {

    init(activityCount: Int) {
        if activityCount == 0 {
            self = .none
        } else if activityCount == 1 {
            self = .single
        } else {
            self = .multiple(min(activityCount, 9))
        }
    }
}

final class ArchiveCalendar: BaseUIView {

    // MARK: - Properties

    var onSelectDay: ((CalendarCellModel) -> Void)?

    private var days: [CalendarCellModel] = []

    private let weekDayArray = ["Mon", "Tue", "Wed", "Thu", "Fri", "Sat", "Sun"]

    // MARK: - UI Properties

    private lazy var weekDayStackView = UIStackView(
        arrangedSubviews: weekDayArray.map {
            let label = UILabel()
            label.text = $0
            label.font = .label_m_12
            label.textColor = .grey_400
            label.textAlignment = .center
            label.snp.makeConstraints {
                $0.width.equalTo(38)
            }
            return label
        }
    )

    private let flowLayout = UICollectionViewFlowLayout()

    private lazy var collectionView = UICollectionView(
        frame: .zero,
        collectionViewLayout: flowLayout
    )

    // MARK: - UI Setting

    override func setStyle() {
        weekDayStackView.do {
            $0.axis = .horizontal
            $0.distribution = .fill
            $0.alignment = .center
        }

        flowLayout.do {
            $0.scrollDirection = .vertical
            $0.itemSize = CGSize(width: 38, height: 38)
            $0.minimumLineSpacing = 14
            $0.sectionInset = UIEdgeInsets(
                top: 20,
                left: 9,
                bottom: 0,
                right: 9
            )
        }

        collectionView.do {
            $0.backgroundColor = .clear
            $0.isScrollEnabled = false
            $0.showsVerticalScrollIndicator = false
            $0.dataSource = self
            $0.delegate = self
            $0.register(
                ArchiveCalendarCell.self,
                forCellWithReuseIdentifier: ArchiveCalendarCell.reuseIdentifier
            )
        }
    }

    override func setUI() {
        addSubviews(weekDayStackView, collectionView)
    }

    override func setLayout() {
        weekDayStackView.snp.makeConstraints {
            $0.top.equalToSuperview()
            $0.horizontalEdges.equalToSuperview().inset(9)
            $0.height.equalTo(16)
        }

        collectionView.snp.makeConstraints {
            $0.top.equalTo(weekDayStackView.snp.bottom)
            $0.horizontalEdges.equalToSuperview()
            $0.bottom.equalToSuperview()
        }
    }

    override func layoutSubviews() {
        super.layoutSubviews()

        let interItemSpacing = max(0, calculatedInterItemSpacing())
        weekDayStackView.spacing = interItemSpacing
        flowLayout.minimumInteritemSpacing = interItemSpacing
        flowLayout.invalidateLayout()
    }

    // MARK: - Public Methods

    func configure(days: [CalendarCellModel]) {
        self.days = days
        collectionView.reloadData()
    }
}

// MARK: - Extensions

extension ArchiveCalendar: UICollectionViewDataSource {

    func collectionView(
        _ collectionView: UICollectionView,
        numberOfItemsInSection section: Int
    ) -> Int {
        days.count
    }

    func collectionView(
        _ collectionView: UICollectionView,
        cellForItemAt indexPath: IndexPath
    ) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(
            withReuseIdentifier: ArchiveCalendarCell.reuseIdentifier,
            for: indexPath
        ) as? ArchiveCalendarCell else {
            return UICollectionViewCell()
        }

        cell.configure(with: days[indexPath.item])
        return cell
    }
}

extension ArchiveCalendar: UICollectionViewDelegateFlowLayout {

    func collectionView(
        _ collectionView: UICollectionView,
        shouldSelectItemAt indexPath: IndexPath
    ) -> Bool {
        let day = days[indexPath.item]

        switch day.content {
        case .empty:
            return false

        case .day:
            switch day.recordState {
            case .none:
                return false

            case .single, .multiple:
                return true
            }
        }
    }

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        onSelectDay?(days[indexPath.item])
    }

    private func calculatedInterItemSpacing() -> CGFloat {
        let totalHorizontalInset: CGFloat = 9 * 2
        let totalItemWidth: CGFloat = 38 * 7
        let availableSpacing = collectionView.bounds.width - totalHorizontalInset - totalItemWidth
        let spacingCount: CGFloat = 7 - 1

        return max(0, (availableSpacing / spacingCount) - 0.1)
    }
}
