//
//  MountainMapView.swift
//  Routee-iOS
//
//  Created by 초긍정행운의포춘쿠키 on 7/7/26.
//

import UIKit

import SnapKit
import Then

final class MountainMapView: BaseUIView {

    private enum Metric {
        static let itemCount = 33
    }

    private var levels: [Int] = []

    private let flowLayout = UICollectionViewFlowLayout()

    private lazy var collectionView = UICollectionView(
        frame: .zero,
        collectionViewLayout: flowLayout
    )

    private let lessLabel = UILabel()
    private let intensityImageView = UIImageView()
    private let moreLabel = UILabel()
    private let stackView = UIStackView()

    override func setStyle() {
        backgroundColor = .grey_900
        layer.cornerRadius = .r12
        layer.masksToBounds = true

        flowLayout.do {
            $0.scrollDirection = .vertical
            $0.itemSize = CGSize(width: 22, height: 19)
            $0.minimumInteritemSpacing = 6
            $0.minimumLineSpacing = 6
            $0.sectionInset = .zero
        }

        collectionView.do {
            $0.backgroundColor = .clear
            $0.isScrollEnabled = false
            $0.dataSource = self
            $0.register(
                MountainMapCell.self,
                forCellWithReuseIdentifier: MountainMapCell.reuseIdentifier
            )
        }

        lessLabel.do {
            $0.text = "less"
            $0.textColor = .white30
            $0.font = .label_m_12
        }

        intensityImageView.do {
            $0.image = UIImage(named: "map_intensity")
            $0.contentMode = .scaleAspectFit
        }

        moreLabel.do {
            $0.text = "more"
            $0.textColor = .white30
            $0.font = .label_m_12
        }

        stackView.do {
            $0.axis = .horizontal
            $0.alignment = .center
            $0.spacing = .s6
        }
    }

    override func setUI() {
        addSubviews(collectionView, stackView)
        stackView.addArrangedSubviews(lessLabel, intensityImageView, moreLabel)
    }

    override func setLayout() {
        collectionView.snp.makeConstraints {
            $0.top.equalToSuperview().inset(20)
            $0.bottom.equalToSuperview().inset(37)
            $0.horizontalEdges.equalToSuperview().inset(20)
        }

        stackView.snp.makeConstraints {
            $0.trailing.equalToSuperview().inset(20)
            $0.bottom.equalToSuperview().inset(10)
        }

        intensityImageView.snp.makeConstraints {
            $0.width.equalTo(36)
            $0.height.equalTo(8)
        }
    }

    func configure(levels: [Int]) {
        let visibleLevels = Array(levels.prefix(Metric.itemCount))
        self.levels = visibleLevels + Array(
            repeating: 0,
            count: max(0, Metric.itemCount - visibleLevels.count)
        )
        collectionView.reloadData()
    }
}

extension MountainMapView: UICollectionViewDataSource {

    func collectionView(
        _ collectionView: UICollectionView,
        numberOfItemsInSection section: Int
    ) -> Int {
        levels.count
    }

    func collectionView(
        _ collectionView: UICollectionView,
        cellForItemAt indexPath: IndexPath
    ) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(
            withReuseIdentifier: MountainMapCell.reuseIdentifier,
            for: indexPath
        ) as? MountainMapCell else {
            return UICollectionViewCell()
        }

        cell.configure(level: levels[indexPath.item])
        return cell
    }
}
