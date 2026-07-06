//
//  TabBarViewController.swift
//  Routee-iOS
//
//  Created by 초긍정행운의포춘쿠키 on 7/5/26.
//

import UIKit

import SnapKit
import Then

final class TabBarViewController: UITabBarController {

    // MARK: - Properties

    private let exerciseItem = TabBarItem()
    private let recapItem = TabBarItem()
    private let archiveItem = TabBarItem()
    private let settingItem = TabBarItem()

    private lazy var tabBarItems = [
        exerciseItem,
        recapItem,
        archiveItem,
        settingItem
    ]

    private var didSetInitialSelection = false

    // MARK: - UI Properties

    private let customTabBar = UIView()
    private let selectionView = UIView()

    // MARK: - Life Cycle

    override func viewDidLoad() {
        super.viewDidLoad()

        configureViewControllers()
        configureTabItems()

        setStyle()
        setUI()
        setLayout()

        tabBar.isHidden = true
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()

        guard !didSetInitialSelection else { return }
        didSetInitialSelection = true

        updateSelection(index: 0, animated: false)
    }
}

// MARK: - Configure

private extension TabBarViewController {

    func configureViewControllers() {
        let exercise = UINavigationController(rootViewController: TestExerciseViewController())
        let recap = UINavigationController(rootViewController: TestRecapViewController())
        let archive = UINavigationController(rootViewController: TestArchiveViewController())
        let setting = UINavigationController(rootViewController: TestSettingViewController())

        exercise.navigationBar.isHidden = true
        recap.navigationBar.isHidden = true
        archive.navigationBar.isHidden = true
        setting.navigationBar.isHidden = true

        viewControllers = [
            exercise,
            recap,
            archive,
            setting
        ]
    }

    func configureTabItems() {
        exerciseItem.configure(
            normalImage: .icExerciseNavSmGrey,
            selectedImage: .icExerciseNavSmWhite,
            title: "운동"
        )

        recapItem.configure(
            normalImage: .icRecapNavSmGrey,
            selectedImage: .icRecapNavSmWhite,
            title: "기록 편집"
        )

        archiveItem.configure(
            normalImage: .icArchiveNavSmGrey,
            selectedImage: .icArchiveNavSmWhite,
            title: "아카이브"
        )

        settingItem.configure(
            normalImage: .icSettingNavSmGrey,
            selectedImage: .icSettingNavSmWhite,
            title: "설정"
        )

        for (index, item) in tabBarItems.enumerated() {
            item.tag = index

            item.addTarget(self, action: #selector(tabDidTap(_:)), for: .touchUpInside
            )
        }
    }

    func setStyle() {
        customTabBar.do {
            $0.backgroundColor = .grey900
            $0.layer.cornerRadius = 32
            $0.layer.masksToBounds = true
        }

        selectionView.do {
            $0.backgroundColor = .white10
            $0.layer.cornerRadius = 27
            $0.layer.masksToBounds = true
        }
    }

    func setUI() {
        view.addSubview(customTabBar)

        customTabBar.addSubviews(
            selectionView,
            exerciseItem,
            recapItem,
            archiveItem,
            settingItem
        )
    }

    func setLayout() {
        customTabBar.snp.makeConstraints {
            $0.leading.trailing.equalToSuperview().inset(16)
            $0.bottom.equalTo(view.safeAreaLayoutGuide)
            $0.height.equalTo(62)
        }

        selectionView.snp.makeConstraints {
            $0.leading.equalToSuperview().offset(6)
            $0.top.bottom.equalToSuperview().inset(6)
            $0.width.equalTo(79)
        }

        exerciseItem.snp.makeConstraints {
            $0.leading.equalToSuperview().offset(6)
            $0.top.equalToSuperview().offset(6)
            $0.bottom.equalToSuperview().inset(6)
            $0.width.equalTo(79)
        }

        recapItem.snp.makeConstraints {
            $0.leading.equalTo(exerciseItem.snp.trailing).offset(5)
            $0.top.equalToSuperview().offset(6)
            $0.bottom.equalToSuperview().inset(6)
            $0.width.equalTo(79)
        }

        archiveItem.snp.makeConstraints {
            $0.leading.equalTo(recapItem.snp.trailing).offset(5)
            $0.top.equalToSuperview().offset(6)
            $0.bottom.equalToSuperview().inset(6)
            $0.width.equalTo(79)
        }

        settingItem.snp.makeConstraints {
            $0.leading.equalTo(archiveItem.snp.trailing).offset(5)
            $0.top.equalToSuperview().offset(6)
            $0.bottom.equalToSuperview().inset(6)
            $0.width.equalTo(79)
        }
    }
    func updateSelection(index: Int, animated: Bool = true) {
        selectedIndex = index
        updateItemAppearance(selectedIndex: index)
        moveSelectionView(to: index, animated: animated)
    }

    func updateItemAppearance(selectedIndex: Int) {
        tabBarItems.enumerated().forEach { index, item in
            item.isSelected = index == selectedIndex
        }
    }

    func moveSelectionView(to index: Int, animated: Bool) {
        let targetItem = tabBarItems[index]

        selectionView.snp.remakeConstraints {
            $0.width.equalTo(79)
            $0.top.bottom.equalToSuperview().inset(6)
            $0.centerX.equalTo(targetItem)
        }

        let animation = {
            self.customTabBar.layoutIfNeeded()
        }

        if animated {
            UIView.animate(withDuration: 0.1) {
                animation()
            }
        } else {
            animation()
        }
    }
}

// MARK: - Action

private extension TabBarViewController {

    @objc
    func tabDidTap(_ sender: TabBarItem) {
        updateSelection(index: sender.tag)
    }
}
