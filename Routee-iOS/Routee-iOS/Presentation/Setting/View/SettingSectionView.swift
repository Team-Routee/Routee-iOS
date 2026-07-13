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

    private let model: Model
    private let itemViews: [SettingItemView]

    // MARK: - UI Properties

    private let titleLabel = UILabel()
    private let stackView = UIStackView()

    // MARK: - Initializer

    init(model: Model) {
        self.model = model
        self.itemViews = model.itemTitles.map { SettingItemView(title: $0) }
        super.init(frame: .zero)

        setStyle()
        setUI()
        setLayout()
    }

    required init?(coder: NSCoder) {
        fatalError()
    }

    // MARK: - UI Setting

    private func setStyle() {
        titleLabel.do {
            $0.text = model.title
            $0.textColor = .staticWhite
            $0.font = .title_sb_18
        }

        stackView.do {
            $0.axis = .vertical
            $0.spacing = 16
        }

        itemViews.forEach {
            $0.isUserInteractionEnabled = false
        }
    }

    private func setUI() {
        addSubview(stackView)

        stackView.addArrangedSubview(titleLabel)
        stackView.setCustomSpacing(20, after: titleLabel)

        itemViews.forEach {
            stackView.addArrangedSubview($0)
        }
    }

    private func setLayout() {
        stackView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
    }

    // MARK: - Public Methods

    func setAction(index: Int, target: Any?, action: Selector) {
        guard itemViews.indices.contains(index) else { return }

        itemViews[index].isUserInteractionEnabled = true
        itemViews[index].addTarget(target, action: action, for: .touchUpInside)
    }
}
