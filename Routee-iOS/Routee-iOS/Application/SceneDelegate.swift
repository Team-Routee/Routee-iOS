//
//  SceneDelegate.swift
//  Routee-iOS
//
//  Created by LEESANGYUP on 6/22/26.
//

import AuthenticationServices
import UIKit

import FirebaseCore
import FirebaseRemoteConfig

class SceneDelegate: UIResponder, UIWindowSceneDelegate {
    
    var window: UIWindow?
    private static let maintenanceKey = "ios_maintenance_enabled"
    private static let minimumSupportedVersionKey = "ios_min_supported_version"
    private static let recommendedVersionKey = "ios_recommended_version"
    private static let skippedRecommendationKey = "skippedRecommendedAppVersion"
    private static let appStoreURL = URL(string: "https://apps.apple.com/kr/app/루티-routee-운동기록-사진-편집-아카이브/id6791870747")
    private let keychainService = DefaultKeychainService()
    private var remoteConfigFetch: Task<Void, Never>?
    private var maintenanceRetryWait: Task<Void, Never>?
    private var remoteConfigModalWindow: UIWindow?
    private var maintenanceModal: ActionPrimaryModal?
    private var observesNotifications = false
    
    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        guard let windowScene = (scene as? UIWindowScene) else { return }
        let window = UIWindow(windowScene: windowScene)
        self.window = window
        showInitialScreen(in: window)

        if FirebaseApp.app() != nil {
            let remoteConfig = RemoteConfig.remoteConfig()
            if let minimumFetchInterval = ConfigManager.remoteConfigMinimumFetchInterval {
                let settings = RemoteConfigSettings()
                settings.minimumFetchInterval = minimumFetchInterval
                remoteConfig.configSettings = settings
            }
            remoteConfig.setDefaults([
                Self.maintenanceKey: NSNumber(value: false),
                Self.minimumSupportedVersionKey: "" as NSString,
                Self.recommendedVersionKey: "" as NSString
            ])

            checkRemoteConfig(using: remoteConfig)
        }
    }

    func sceneDidDisconnect(_ scene: UIScene) {
        remoteConfigFetch?.cancel()
        remoteConfigFetch = nil
        maintenanceRetryWait?.cancel()
        maintenanceRetryWait = nil
        dismissRemoteConfigModal()
        window = nil
    }

    func sceneDidBecomeActive(_ scene: UIScene) {
        // Called when the scene has moved from an inactive state to an active state.
        // Use this method to restart any tasks that were paused (or not yet started) when the scene was inactive.
    }
    
    func sceneWillResignActive(_ scene: UIScene) {
        // Called when the scene will move from an active state to an inactive state.
        // This may occur due to temporary interruptions (ex. an incoming phone call).
    }
    
    func sceneWillEnterForeground(_ scene: UIScene) {
        // Called as the scene transitions from the background to the foreground.
        // Use this method to undo the changes made on entering the background.
    }
    
    func sceneDidEnterBackground(_ scene: UIScene) {
        // Called as the scene transitions from the foreground to the background.
        // Use this method to save data, release shared resources, and store enough scene-specific state information
        // to restore the scene back to its current state.
    }
    
    private func checkRemoteConfig(using remoteConfig: RemoteConfig, bypassesCache: Bool = false) {
        guard window != nil, maintenanceRetryWait == nil else { return }

        if bypassesCache {
            maintenanceModal?.setActionsEnabled(false)
            // Allow another tap after three seconds while the same request continues.
            maintenanceRetryWait = Task { [weak self] in
                do {
                    try await Task.sleep(for: .seconds(3))
                } catch {
                    return
                }

                guard !Task.isCancelled, let self else { return }
                maintenanceRetryWait = nil
                maintenanceModal?.setActionsEnabled(true)
            }
        }

        // Share an in-flight retry instead of starting overlapping Firebase requests.
        guard remoteConfigFetch == nil else { return }
        remoteConfigFetch = Task { [weak self] in
            guard !Task.isCancelled else { return }

            do {
                if bypassesCache {
                    let status = try await remoteConfig.fetch(withExpirationDuration: 0)
                    if status == .success, !Task.isCancelled {
                        _ = try await remoteConfig.activate()
                    }
                } else {
                    _ = try await remoteConfig.fetchAndActivate()
                }
            } catch {
                RouteeLogger.debug("Remote Config fetch failed (code \((error as NSError).code))")
            }

            guard !Task.isCancelled, let self else { return }
            remoteConfigFetch = nil
            maintenanceRetryWait?.cancel()
            maintenanceRetryWait = nil
            applyRemoteConfig(using: remoteConfig)
        }
    }

    private func applyRemoteConfig(using remoteConfig: RemoteConfig) {
        guard window != nil else { return }

        if remoteConfig[Self.maintenanceKey].boolValue {
            if let maintenanceModal {
                maintenanceModal.setActionsEnabled(true)
                return
            }

            let retry: () -> Void = { [weak self] in
                self?.checkRemoteConfig(using: remoteConfig, bypassesCache: true)
            }

            let modal = ActionPrimaryModal(
                title: "서비스 점검 중이에요",
                description: "더 나은 루티를 위해 점검하고 있어요.\n잠시 후 다시 이용해주세요.",
                actionCount: .single,
                leftButtonTitle: "확인",
                dismissOnAction: false,
                dismissOnBackgroundTap: false,
                leftButtonAction: retry
            )

            showRemoteConfigModal(modal)
            maintenanceModal = modal
        } else {
            dismissRemoteConfigModal()
            showUpdateModalIfNeeded(using: remoteConfig)
        }
    }

    private func showUpdateModalIfNeeded(using remoteConfig: RemoteConfig) {
        let requirement = AppUpdateRequirement(
            currentVersion: Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as? String,
            minimumSupportedVersion: remoteConfig[Self.minimumSupportedVersionKey].stringValue,
            recommendedVersion: remoteConfig[Self.recommendedVersionKey].stringValue,
            skippedRecommendation: UserDefaults.standard.string(forKey: Self.skippedRecommendationKey)
        )

        switch requirement {
        case .none:
            return
        case .required:
            let update: () -> Void = {
                Self.openAppStore()
            }

            let modal = ActionPrimaryModal(
                title: "업데이트가 필요해요",
                description: "더 안정적인 루티를 위해\n최신 버전으로 업데이트해주세요.",
                actionCount: .single,
                leftButtonTitle: "업데이트",
                primaryButtonTitleColor: .white,
                dismissOnAction: false,
                dismissOnBackgroundTap: false,
                leftButtonAction: update
            )

            showRemoteConfigModal(modal)
        case .recommended(let version):
            let later: () -> Void = { [weak self] in
                UserDefaults.standard.set(version, forKey: Self.skippedRecommendationKey)
                self?.dismissRemoteConfigModal()
            }

            let update: () -> Void = { [weak self] in
                self?.dismissRemoteConfigModal()
                Self.openAppStore()
            }

            let modal = ActionPrimaryModal(
                title: "새로운 버전이 나왔어요",
                description: "업데이트하고 더 편해진\n루티를 만나보세요.",
                leftButtonTitle: "나중에",
                rightButtonTitle: "업데이트",
                primaryButtonTitleColor: .white,
                dismissOnAction: false,
                dismissOnBackgroundTap: false,
                leftButtonAction: later,
                rightButtonAction: update
            )

            showRemoteConfigModal(modal)
        }
    }

    private func showRemoteConfigModal(_ modal: ActionPrimaryModal) {
        guard let windowScene = window?.windowScene else { return }
        window?.endEditing(true)

        // Keep the modal above root changes caused by login or token expiration.
        let modalWindow = UIWindow(windowScene: windowScene)
        modalWindow.backgroundColor = .clear
        modalWindow.isOpaque = false
        modalWindow.windowLevel = UIWindow.Level(rawValue: UIWindow.Level.normal.rawValue + 1)
        modalWindow.rootViewController = modal
        modal.view.accessibilityViewIsModal = true
        remoteConfigModalWindow = modalWindow
        // Keep the app window key so existing screen and loading-overlay logic still works.
        modalWindow.isHidden = false
    }

    private func dismissRemoteConfigModal() {
        remoteConfigModalWindow?.isHidden = true
        remoteConfigModalWindow?.rootViewController = nil
        remoteConfigModalWindow = nil
        maintenanceModal = nil
    }

    private static func openAppStore() {
        guard let appStoreURL else { return }
        UIApplication.shared.open(appStoreURL)
    }

    private func showInitialScreen(in window: UIWindow) {
        if keychainService.read(.refreshToken).isEmpty {
            let viewController = LoginViewController()
            let navigationViewController = UINavigationController(rootViewController: viewController)
            navigationViewController.navigationBar.isHidden = true
            window.rootViewController = navigationViewController
        } else {
            window.rootViewController = TabBarViewController()
        }

        window.makeKeyAndVisible()
        addNotificationObserver()
        checkAppleCredentialState()
    }

    private func addNotificationObserver() {
        guard !observesNotifications else { return }
        observesNotifications = true

        NotificationCenter.default.addObserver(
            self,
            selector: #selector(navigateLoginViewController),
            name: .navigateLoginViewController,
            object: nil
        )

        NotificationCenter.default.addObserver(
            self,
            selector: #selector(navigateLoginViewController),
            name: .signUpCompleted,
            object: nil
        )
        
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(appleCredentialRevoked),
            name: ASAuthorizationAppleIDProvider.credentialRevokedNotification,
            object: nil
        )
    }
    
    @objc
    private func navigateLoginViewController(_ notification: Notification) {
        guard let window else { return }

        let loginViewController = LoginViewController(
            showSignUpCompletionModal: notification.name == .signUpCompleted
        )
        
        let navigationController = UINavigationController(
            rootViewController: loginViewController
        )
        
        navigationController.navigationBar.isHidden = true
        window.rootViewController = navigationController
    }
    
    @objc
    nonisolated private func appleCredentialRevoked() {
        Task {
            @MainActor [weak self] in
            self?.forceLogout()
        }
    }
    
    private func checkAppleCredentialState() {
        let appleUserID = keychainService.read(.appleUserID)
        
        guard !appleUserID.isEmpty else { return }
        
        Task {
            @MainActor [weak self] in
            let state = try? await ASAuthorizationAppleIDProvider()
                .credentialState(forUserID: appleUserID)
            
            guard let self, state == .revoked else { return }
            self.forceLogout()
        }
    }
    
    private func forceLogout() {
        for key in KeyType.allCases {
            keychainService.delete(key)
        }
        NotificationCenter.default.post(name: .navigateLoginViewController, object: nil)
    }
    
}

private enum AppUpdateRequirement: Equatable {
    case none
    case required
    case recommended(version: String)

    init(
        currentVersion: String?,
        minimumSupportedVersion: String,
        recommendedVersion: String,
        skippedRecommendation: String?
    ) {
        guard let currentVersion, let current = AppVersion(currentVersion) else {
            self = .none
            return
        }

        if let minimum = AppVersion(minimumSupportedVersion), current < minimum {
            self = .required
            return
        }

        if let recommended = AppVersion(recommendedVersion),
           current < recommended,
           recommended.normalizedValue != skippedRecommendation {
            self = .recommended(version: recommended.normalizedValue)
            return
        }

        self = .none
    }
}

private struct AppVersion: Comparable {
    private let components: [Int]

    var normalizedValue: String {
        components.map(String.init).joined(separator: ".")
    }

    init?(_ value: String) {
        let parts = value.trimmingCharacters(in: .whitespacesAndNewlines)
            .split(separator: ".", omittingEmptySubsequences: false)
        
        guard (1...3).contains(parts.count) else { return nil }

        let numbers = parts.compactMap { part -> Int? in
            guard part.allSatisfy({ $0.isASCII && $0.isNumber }) else { return nil }
            return Int(part)
        }
        
        guard numbers.count == parts.count else { return nil }

        components = numbers + Array(repeating: 0, count: 3 - numbers.count)
    }

    static func < (lhs: Self, rhs: Self) -> Bool {
        lhs.components.lexicographicallyPrecedes(rhs.components)
    }
}
