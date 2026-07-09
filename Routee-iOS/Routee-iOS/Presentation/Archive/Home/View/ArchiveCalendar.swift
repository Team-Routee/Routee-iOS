//
//  Calendar.swift
//  Routee-iOS
//
//  Created by 초긍정행운의포춘쿠키 on 7/8/26.
//

import UIKit

import SnapKit
import Then

final class ArchiveCalendar: BaseUIView {

    // MARK: - Properties

    var onSelectDay: ((DayCellModel) -> Void)?

    private var days: [DayCellModel] = []

    private enum Metric {
        static let sectionHorizontalInset: CGFloat = 9
        static let lineSpacing: CGFloat = 14
        static let itemSize = CGSize(width: 38, height: 38)
        static let columnCount: CGFloat = 7
        static let spacingEpsilon: CGFloat = 0.1
    }

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
                $0.width.equalTo(Metric.itemSize.width)
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
            $0.itemSize = Metric.itemSize
            $0.minimumLineSpacing = Metric.lineSpacing
            $0.sectionInset = UIEdgeInsets(
                top: 20,
                left: Metric.sectionHorizontalInset,
                bottom: 0,
                right: Metric.sectionHorizontalInset
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
            $0.horizontalEdges.equalToSuperview().inset(Metric.sectionHorizontalInset)
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

    func configure(days: [DayCellModel]) {
        self.days = days
        collectionView.reloadData()
    }

    static func makeDays(
        year: Int,
        month: Int,
        records: [RecordModel]
    ) -> [DayCellModel] {
        let recordsByDay = Dictionary(
            uniqueKeysWithValues: records.compactMap { record -> (Int, RecordModel)? in
                guard let dayValue = day(from: record.activityDate) else { return nil }
                return (dayValue, record)
            }
        )

        var days = Array(
            repeating: DayCellModel(
                content: .empty,
                recordState: .none,
                coverImageName: nil,
                activityDate: nil
            ),
            count: leadingEmptyCount(year: year, month: month)
        )

        for dayValue in 1...numberOfDays(year: year, month: month) {
            let record = recordsByDay[dayValue]
            days.append(
                DayCellModel(
                    content: .day(dayValue),
                    recordState: .init(activityCount: record?.activityCount ?? 0),
                    coverImageName: record?.coverImageName,
                    activityDate: record?.activityDate
                )
            )
        }

        return days
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

            case .background, .badge:
                return true
            }
        }
    }

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        onSelectDay?(days[indexPath.item])
    }

    private func calculatedInterItemSpacing() -> CGFloat {
        let totalHorizontalInset = Metric.sectionHorizontalInset * 2
        let totalItemWidth = Metric.itemSize.width * Metric.columnCount
        let availableSpacing = collectionView.bounds.width - totalHorizontalInset - totalItemWidth
        let spacingCount = Metric.columnCount - 1

        guard spacingCount > 0 else { return 0 }
        return max(0, (availableSpacing / spacingCount) - Metric.spacingEpsilon)
    }
}

private extension ArchiveCalendar {
    static func day(from activityDate: String) -> Int? {
        Int(activityDate.split(separator: "-").last ?? "")
    }

    static func leadingEmptyCount(year: Int, month: Int) -> Int {
        var components = DateComponents()
        components.year = year
        components.month = month
        components.day = 1

        guard let date = Foundation.Calendar.current.date(from: components) else { return 0 }

        let weekday = Foundation.Calendar.current.component(.weekday, from: date)
        return (weekday + 5) % 7
    }

    static func numberOfDays(year: Int, month: Int) -> Int {
        var components = DateComponents()
        components.year = year
        components.month = month

        guard
            let date = Foundation.Calendar.current.date(from: components),
            let range = Foundation.Calendar.current.range(of: .day, in: .month, for: date)
        else { return 30 }

        return range.count
    }
}
