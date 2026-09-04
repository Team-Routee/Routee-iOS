//
//  TabBarViewController.swift
//  Routee-iOS
//
//  Created by 초긍정행운의포춘쿠키 on 7/5/26.
//

import UIKit

import SnapKit

final class TabBarViewController: UITabBarController {

    // MARK: - Properties

    private var activeTab: AppTab = .workout
    private var navigationControllers: [AppTab: UINavigationController] = [:]
    private var isCustomTabBarHidden = false

    // MARK: - UI Properties

    private let customTabBarView = CustomTabBarView()

    // MARK: - Life Cycle

    override func viewDidLoad() {
        super.viewDidLoad()

        configureViewControllers()
        configureCustomTabBar()
        setUI()
        setLayout()
        select(.workout, reset: .none, animated: false)

        tabBar.isHidden = true
    }

    // MARK: - Configure

    private func configureViewControllers() {
        AppTab.allCases.forEach { tab in
            let navigationController = UINavigationController(
                rootViewController: makeRootViewController(for: tab)
            )
            navigationController.navigationBar.isHidden = true
            navigationController.delegate = self
            navigationControllers[tab] = navigationController
        }

        viewControllers = AppTab.allCases.compactMap { navigationControllers[$0] }
    }

    private func configureCustomTabBar() {
        customTabBarView.onSelectTab = { [weak self] tab in
            self?.select(tab, reset: .none, animated: true)
        }
    }

    private func makeRootViewController(for tab: AppTab) -> UIViewController {
        switch tab {
        case .workout: WorkoutViewController()
        case .recordEdit: RecordEditViewController()
        case .archive: ArchiveViewController()
        case .setting: SettingViewController()
        }
    }

    // MARK: - UI Setting

    private func setUI() {
        view.addSubview(customTabBarView)
    }

    private func setLayout() {
        customTabBarView.snp.makeConstraints {
            $0.centerX.equalToSuperview()
            $0.bottom.equalTo(view.safeAreaLayoutGuide)
            $0.width.equalTo(343)
            $0.height.equalTo(CustomTabBarView.height)
        }
    }

    // MARK: - Private Methods

    private func resetNavigationStacks(
        currentTab: AppTab,
        destinationTab: AppTab,
        policy: TabNavigationResetPolicy
    ) {
        switch policy {
        case .none:
            break
        case .destination:
            navigationControllers[destinationTab]?.popToRootViewController(animated: false)
        case .currentAndDestination:
            navigationControllers[currentTab]?.popToRootViewController(animated: false)

            guard currentTab != destinationTab else { return }
            navigationControllers[destinationTab]?.popToRootViewController(animated: false)
        }
    }

    private func resolvedVisibility(
        for viewController: UIViewController,
        in navigationController: UINavigationController
    ) -> TabBarVisibility {
        let preferredVisibility = (viewController as? TabBarAppearanceProviding)?
            .preferredTabBarVisibility ?? .automatic

        switch preferredVisibility {
        case .automatic:
            return navigationController.viewControllers.first === viewController ? .visible : .hidden
        case .visible, .hidden:
            return preferredVisibility
        }
    }

    private func apply(_ visibility: TabBarVisibility, animated: Bool) {
        let shouldHide = visibility == .hidden
        let bottomInset = shouldHide
            ? 0
            : CustomTabBarView.height

        selectedViewController?.additionalSafeAreaInsets.bottom = bottomInset

        guard shouldHide != isCustomTabBarHidden else { return }

        isCustomTabBarHidden = shouldHide
        customTabBarView.setHidden(shouldHide, animated: animated)
    }
}

// MARK: - AppTabRouting

extension TabBarViewController: AppTabRouting {
    func select(
        _ tab: AppTab,
        reset: TabNavigationResetPolicy,
        animated: Bool
    ) {
        guard let index = AppTab.allCases.firstIndex(of: tab) else { return }

        let previousTab = activeTab
        resetNavigationStacks(
            currentTab: previousTab,
            destinationTab: tab,
            policy: reset
        )

        activeTab = tab
        selectedIndex = index
        customTabBarView.setSelectedTab(tab, animated: animated)
        updateTabBarAppearance(animated: animated)
    }
}

// MARK: - TabBarAppearanceUpdating

extension TabBarViewController: TabBarAppearanceUpdating {
    func updateTabBarAppearance(animated: Bool) {
        guard
            let navigationController = navigationControllers[activeTab],
            let topViewController = navigationController.topViewController
        else { return }

        let visibility = resolvedVisibility(
            for: topViewController,
            in: navigationController
        )
        apply(visibility, animated: animated)
    }
}

// MARK: - UINavigationControllerDelegate

extension TabBarViewController: UINavigationControllerDelegate {
    func navigationController(
        _ navigationController: UINavigationController,
        willShow viewController: UIViewController,
        animated: Bool
    ) {
        guard navigationController === selectedViewController else { return }

        let visibility = resolvedVisibility(
            for: viewController,
            in: navigationController
        )
        apply(visibility, animated: animated)
    }
}
