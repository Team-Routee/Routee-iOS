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

    // MARK: - Properties
    
    static let reuseIdentifier = "MountainMapCell"

    // MARK: - UI Properties
    
    private let mountainMapItem = UIImageView()

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
        mountainMapItem.do {
            $0.contentMode = .scaleAspectFit
        }
    }

    private func setUI() {
        contentView.addSubview(mountainMapItem)
    }

    private func setLayout() {
        mountainMapItem.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
    }
    
    // MARK: - Public Methods
    
    func configure(level: Int) {
        let clampedLevel = min(max(level, 0), 4)
        mountainMapItem.image = UIImage(named: "activityLevel\(clampedLevel)")
    }

}
