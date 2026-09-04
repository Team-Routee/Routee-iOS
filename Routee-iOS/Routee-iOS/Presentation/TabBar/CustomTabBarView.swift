//
//  CustomTabBarView.swift
//  Routee-iOS
//
//  Created by LEESANGYUP on 9/4/26.
//

import UIKit

import SnapKit
import Then

final class CustomTabBarView: UIView {

    static let height: CGFloat = 62

    // MARK: - Properties

    var onSelectTab: ((AppTab) -> Void)?

    private var tabItems: [AppTab: TabBarItem] = [:]

    // MARK: - UI Properties

    private let selectionView = UIView()
    private let itemStackView = UIStackView()

    // MARK: - Initializer

    override init(frame: CGRect) {
        super.init(frame: frame)

        configureItems()
        setStyle()
        setUI()
        setLayout()
        setSelectedTab(.workout, animated: false)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - UI Setting

    private func setStyle() {
        backgroundColor = .grey900
        layer.cornerRadius = 32
        layer.masksToBounds = true

        selectionView.do {
            $0.backgroundColor = .white10
            $0.layer.cornerRadius = 25
            $0.layer.masksToBounds = true
        }

        itemStackView.do {
            $0.axis = .horizontal
            $0.alignment = .fill
            $0.distribution = .fillEqually
            $0.spacing = 5
        }
    }

    private func setUI() {
        addSubviews(selectionView, itemStackView)

        AppTab.allCases.forEach { tab in
            guard let item = tabItems[tab] else { return }
            itemStackView.addArrangedSubview(item)
        }
    }

    private func setLayout() {
        selectionView.snp.makeConstraints {
            $0.top.bottom.equalToSuperview().inset(6)
            $0.width.equalTo(79)
            $0.leading.equalToSuperview().inset(6)
        }

        itemStackView.snp.makeConstraints {
            $0.edges.equalToSuperview().inset(6)
        }
    }

    // MARK: - Configure

    private func configureItems() {
        AppTab.allCases.forEach { tab in
            let item = TabBarItem()
            item.configure(
                normalImage: tab.normalImage,
                selectedImage: tab.selectedImage,
                title: tab.title
            )
            item.addAction(
                UIAction { [weak self] _ in
                    self?.onSelectTab?(tab)
                },
                for: .touchUpInside
            )
            tabItems[tab] = item
        }
    }

    // MARK: - Public Methods

    func setSelectedTab(_ selectedTab: AppTab, animated: Bool) {
        tabItems.forEach { tab, item in
            item.isSelected = tab == selectedTab
        }

        guard let selectedItem = tabItems[selectedTab] else { return }

        selectionView.snp.remakeConstraints {
            $0.top.bottom.equalToSuperview().inset(6)
            $0.width.equalTo(79)
            $0.centerX.equalTo(selectedItem)
        }

        let animations = { self.layoutIfNeeded() }

        if animated {
            UIView.animate(withDuration: 0.1, animations: animations)
        } else {
            animations()
        }
    }

    func setHidden(_ isHidden: Bool, animated: Bool) {
        guard self.isHidden != isHidden || alpha != (isHidden ? 0 : 1) else { return }

        if !isHidden {
            self.isHidden = false
        }

        let animations = {
            self.alpha = isHidden ? 0 : 1
            self.transform = isHidden
                ? CGAffineTransform(translationX: 0, y: Self.height)
                : .identity
        }

        let completion: (Bool) -> Void = { [weak self] finished in
            guard finished, isHidden else { return }
            self?.isHidden = true
        }

        if animated {
            UIView.animate(
                withDuration: 0.2,
                animations: animations,
                completion: completion
            )
        } else {
            animations()
            completion(true)
        }
    }
}
