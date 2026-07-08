//
//  MountainMapCell.swift
//  Routee-iOS
//
//  Created by 초긍정행운의포춘쿠키 on 7/7/26.
//

import UIKit

import SnapKit
import Then

final class MountainMapCell: UICollectionViewCell {

    static let reuseIdentifier = "MountainMapCell"

    private let imageView = UIImageView()

    override init(frame: CGRect) {
        super.init(frame: frame)

        setStyle()
        setUI()
        setLayout()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func configure(level: Int) {
        let clampedLevel = min(max(level, 0), 4)
        imageView.image = UIImage(named: "activityLevel\(clampedLevel)")
    }

    private func setStyle() {
        imageView.do {
            $0.contentMode = .scaleAspectFit
        }
    }

    private func setUI() {
        contentView.addSubview(imageView)
    }

    private func setLayout() {
        imageView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
    }
}
