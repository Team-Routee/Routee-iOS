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
    
    static let customTabBarHeight: CGFloat = 62
    
    // MARK: - Properties
    
    private let workoutItem = TabBarItem()
    private let recordEditItem = TabBarItem()
    private let archiveItem = TabBarItem()
    private let settingItem = TabBarItem()
    
    private lazy var tabBarItems = [
        workoutItem,
        recordEditItem,
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
    
    // MARK: - Configure
    
    private func configureViewControllers() {
        let workout = UINavigationController(rootViewController: SampleViewController())
        let recordEdit = UINavigationController(rootViewController: RecordEditViewController())
        let archive = UINavigationController(rootViewController: SampleViewController())
        let setting = UINavigationController(rootViewController: SampleViewController())
        
        [workout, recordEdit, archive, setting].forEach { $0.navigationBar.isHidden = true }
        
        viewControllers = [
            workout,
            recordEdit,
            archive,
            setting
        ]
    }
    
    private func configureTabItems() {
        workoutItem.configure(
            normalImage: .icExerciseNavSmGrey,
            selectedImage: .icExerciseNavSmWhite,
            title: "운동"
        )
        
        recordEditItem.configure(
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
        
        tabBarItems.enumerated().forEach { index, item in
            item.tag = index
            
            item.addTarget(
                self,
                action: #selector(tabDidTap(_:)),
                for: .touchUpInside
            )
        }
    }
    
    // MARK: - UI Setting
    
    private func setStyle() {
        customTabBar.do {
            $0.backgroundColor = .grey900
            $0.layer.cornerRadius = 31
            $0.layer.masksToBounds = true
        }
        
        selectionView.do {
            $0.backgroundColor = .white10
            $0.layer.cornerRadius = 25
            $0.layer.masksToBounds = true
        }
    }
    
    private func setUI() {
        view.addSubview(customTabBar)
        
        customTabBar.addSubviews(
            selectionView,
            workoutItem,
            recordEditItem,
            archiveItem,
            settingItem
        )
    }
    
    private func setLayout() {
        customTabBar.snp.makeConstraints {
            $0.centerX.equalToSuperview()
            $0.bottom.equalTo(view.safeAreaLayoutGuide)
            $0.width.equalTo(343)
            $0.height.equalTo(Self.customTabBarHeight)
        }
        
        selectionView.snp.makeConstraints {
            $0.top.leading.equalToSuperview().inset(6)
            $0.width.equalTo(79)
            $0.height.equalTo(50)
        }
        
        workoutItem.snp.makeConstraints {
            $0.leading.equalToSuperview().inset(6)
            $0.top.bottom.equalToSuperview().inset(6)
            $0.width.equalTo(79)
        }
        
        recordEditItem.snp.makeConstraints {
            $0.leading.equalTo(workoutItem.snp.trailing).offset(5)
            $0.top.bottom.equalToSuperview().inset(6)
            $0.width.equalTo(79)
        }
        
        archiveItem.snp.makeConstraints {
            $0.leading.equalTo(recordEditItem.snp.trailing).offset(5)
            $0.top.bottom.equalToSuperview().inset(6)
            $0.width.equalTo(79)
        }
        
        settingItem.snp.makeConstraints {
            $0.leading.equalTo(archiveItem.snp.trailing).offset(5)
            $0.top.bottom.equalToSuperview().inset(6)
            $0.width.equalTo(79)
        }
    }
    
    // MARK: - Private Methods
    
    private func updateSelection(index: Int, animated: Bool = true) {
        selectedIndex = index
        updateItemAppearance(selectedIndex: index)
        moveSelectionView(to: index, animated: animated)
    }
    
    private func updateItemAppearance(selectedIndex: Int) {
        tabBarItems.enumerated().forEach { index, item in
            item.isSelected = index == selectedIndex
        }
    }
    
    private func moveSelectionView(to index: Int, animated: Bool) {
        let targetItem = tabBarItems[index]
        
        selectionView.snp.remakeConstraints {
            $0.width.equalTo(79)
            $0.top.bottom.equalToSuperview().inset(6)
            $0.centerX.equalTo(targetItem)
        }
        
        let animation = { self.customTabBar.layoutIfNeeded() }
        
        if animated {
            UIView.animate(withDuration: 0.1) {
                animation()
            }
        } else {
            animation()
        }
    }
    
    // MARK: - Actions
    
    @objc
    private func tabDidTap(_ sender: TabBarItem) {
        updateSelection(index: sender.tag)
    }
}
