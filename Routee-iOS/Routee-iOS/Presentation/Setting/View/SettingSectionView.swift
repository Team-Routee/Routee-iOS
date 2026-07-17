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

    // MARK: - Properties

    struct Model {
        let title: String
        let itemTitles: [String]
    }

    private var itemViews: [SettingItemView] = []

    // MARK: - UI Properties

    private let titleLabel = UILabel()
    private let sectionStackView = UIStackView()

    // MARK: - Initializer

    override init(frame: CGRect) {
        super.init(frame: frame)

        setStyle()
        setUI()
        setLayout()
    }

    convenience init(model: Model) {
        self.init(frame: .zero)

        configure(model: model)
    }

    required init?(coder: NSCoder) {
        fatalError()
    }

    // MARK: - UI Setting

    private func setStyle() {
        titleLabel.do {
            $0.textColor = .staticWhite
            $0.font = .title_sb_18
        }

        sectionStackView.do {
            $0.axis = .vertical
            $0.spacing = 18
        }
    }

    private func setUI() {
        addSubview(sectionStackView)

        sectionStackView.addArrangedSubview(titleLabel)
        sectionStackView.setCustomSpacing(20, after: titleLabel)

        itemViews.forEach {
            sectionStackView.addArrangedSubview($0)
        }
    }

    private func setLayout() {
        sectionStackView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
    }

    // MARK: - Public Methods

    func configure(model: Model) {
        titleLabel.text = model.title

        itemViews.forEach {
            sectionStackView.removeArrangedSubview($0)
            $0.removeFromSuperview()
        }

        itemViews = model.itemTitles.map {
            SettingItemView(title: $0)
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
