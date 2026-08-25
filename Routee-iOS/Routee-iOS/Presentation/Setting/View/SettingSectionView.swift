//
//  SettingSectionView.swift
//  Routee-iOS
//
//  Created by 김세령 on 7/13/26.
//

import UIKit

import SnapKit
import Then

final class SettingSectionView: UIView {

    // MARK: - UI Properties

    private let sectionTitleLabel = UILabel()
    private let sectionStackView = UIStackView()
    private var itemViews: [SettingItemView] = []

    // MARK: - Initializer

    override init(frame: CGRect) {
        super.init(frame: frame)

        setStyle()
        setUI()
        setLayout()
    }

    required init?(coder: NSCoder) {
        fatalError()
    }

    // MARK: - UI Setting

    private func setStyle() {
        backgroundColor = .grey900
        layer.cornerRadius = .r12
        layer.masksToBounds = true

        sectionTitleLabel.do {
            $0.textColor = .grey200
            $0.font = .label_r_12
        }

        sectionStackView.do {
            $0.axis = .vertical
            $0.spacing = 0
        }
    }

    private func setUI() {
        addSubview(sectionStackView)

        sectionStackView.addArrangedSubview(sectionTitleLabel)
        sectionStackView.setCustomSpacing(10, after: sectionTitleLabel)

        itemViews.forEach {
            sectionStackView.addArrangedSubview($0)
        }
    }

    private func setLayout() {
        snp.makeConstraints {
            $0.height.equalTo(178)
        }

        sectionStackView.snp.makeConstraints {
            $0.leading.equalToSuperview().inset(18)
            $0.trailing.equalToSuperview().inset(14)
            $0.top.equalToSuperview().inset(18)
            $0.bottom.equalToSuperview().inset(10)
        }
    }

    // MARK: - Public Methods

    func configure(title: String, itemTitles: [String]) {
        configure(
            title: title,
            items: itemTitles.map { (title: $0, trailingText: nil) }
        )
    }

    func configure(title: String, items: [(title: String, trailingText: String?)]) {
        sectionTitleLabel.text = title

        itemViews.forEach {
            sectionStackView.removeArrangedSubview($0)
            $0.removeFromSuperview()
        }

        itemViews = items.map {
            SettingItemView(title: $0.title, trailingText: $0.trailingText)
        }

        itemViews.forEach {
            sectionStackView.addArrangedSubview($0)
        }
    }

    func setAction(index: Int, target: Any?, action: Selector) {
        guard itemViews.indices.contains(index) else { return }

        itemViews[index].setAction(target: target, action: action)
    }
}
