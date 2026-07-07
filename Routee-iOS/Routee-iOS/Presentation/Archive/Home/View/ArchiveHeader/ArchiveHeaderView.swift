//
//  ArchiveHeaderView.swift
//  Routee-iOS
//
//  Created by 초긍정행운의포춘쿠키 on 7/7/26.
//

import UIKit

import SnapKit
import Then

final class ArchiveHeaderView: BaseUIView {

    private let titleLabel = UILabel()

    override func setStyle() {
        titleLabel.do {
            $0.text = "아카이브"
            $0.textColor = .static_white
            $0.font = .title_sb_20
        }
    }

    override func setUI() {
        addSubview(titleLabel)
    }

    override func setLayout() {
        titleLabel.snp.makeConstraints {
            $0.top.leading.bottom.equalToSuperview().inset(16)
        }
    }
}
