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
    private var maintenanceFetch: (task: Task<Void, Never>, bypassesCache: Bool)?
    private var maintenanceWait: Task<Void, Never>?
    private var observesNotifications = false
    
    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        guard let windowScene = (scene as? UIWindowScene) else { return }
        let window = UIWindow(windowScene: windowScene)
        self.window = window

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

            let loadingViewController = StartupLoadingViewController()
            loadingViewController.onFirstAppearance = { [weak self] in
                self?.checkMaintenance(using: remoteConfig, maximumWait: .seconds(1))
            }
            window.rootViewController = loadingViewController
            window.makeKeyAndVisible()
            return
        }

        showInitialScreen(in: window)
    }

    func sceneDidDisconnect(_ scene: UIScene) {
        maintenanceFetch?.task.cancel()
        maintenanceFetch = nil
        maintenanceWait?.cancel()
        maintenanceWait = nil
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
    
    private func checkMaintenance(
        using remoteConfig: RemoteConfig,
        maximumWait: Duration,
        bypassesCache: Bool = false
    ) {
        guard maintenanceWait == nil,
              let loadingViewController = window?.rootViewController as? StartupLoadingViewController else { return }

        let modal = loadingViewController.presentedViewController as? ActionPrimaryModal
        modal?.setActionsEnabled(false)

        if maintenanceFetch == nil || (bypassesCache && maintenanceFetch?.bypassesCache == false) {
            let previousFetch = maintenanceFetch?.task
            previousFetch?.cancel()

            let task = Task { [weak self] in
                // Firebase may reuse the previous result if two requests overlap.
                await previousFetch?.value
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
                maintenanceFetch = nil
                finishMaintenanceCheck(using: remoteConfig)
            }
            maintenanceFetch = (task, bypassesCache)
        }

        // Bound the UI wait even if Firebase Installations is still preparing a token.
        maintenanceWait = Task { [weak self] in
            do {
                try await Task.sleep(for: maximumWait)
            } catch {
                return
            }

            self?.finishMaintenanceCheck(using: remoteConfig)
        }
    }

    private func finishMaintenanceCheck(using remoteConfig: RemoteConfig) {
        guard let maintenanceWait else { return }
        maintenanceWait.cancel()
        self.maintenanceWait = nil

        guard let window,
              let loadingViewController = window.rootViewController as? StartupLoadingViewController else { return }

        let modal = loadingViewController.presentedViewController as? ActionPrimaryModal
        if remoteConfig[Self.maintenanceKey].boolValue {
            loadingViewController.stopLoading()
            if let modal {
                modal.setActionsEnabled(true)
                return
            }

            let retry: () -> Void = { [weak self] in
                self?.checkMaintenance(using: remoteConfig, maximumWait: .seconds(3), bypassesCache: true)
            }
            
            let maintenanceModal = ActionPrimaryModal(
                title: "서비스 점검 중이에요",
                description: "더 나은 루티를 위해 점검하고 있어요.\n잠시 후 다시 이용해주세요.",
                actionCount: .single,
                leftButtonTitle: "확인",
                dismissOnAction: false,
                dismissOnBackgroundTap: false,
                leftButtonAction: retry
            )
            
            loadingViewController.present(maintenanceModal, animated: true)
        } else if let modal {
            modal.dismiss(animated: false) { [weak self] in
                guard let self, self.window === window else { return }
                continueAfterMaintenance(using: remoteConfig, in: window)
            }
        } else {
            continueAfterMaintenance(using: remoteConfig, in: window)
        }
    }

    private func continueAfterMaintenance(using remoteConfig: RemoteConfig, in window: UIWindow) {
        guard let loadingViewController = window.rootViewController as? StartupLoadingViewController else { return }

        let requirement = AppUpdateRequirement(
            currentVersion: Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as? String,
            minimumSupportedVersion: remoteConfig[Self.minimumSupportedVersionKey].stringValue,
            recommendedVersion: remoteConfig[Self.recommendedVersionKey].stringValue,
            skippedRecommendation: UserDefaults.standard.string(forKey: Self.skippedRecommendationKey)
        )

        switch requirement {
        case .none:
            showInitialScreen(in: window)
        case .required:
            loadingViewController.stopLoading()

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
            
            loadingViewController.present(modal, animated: true)
        case .recommended(let version):
            loadingViewController.stopLoading()

            let proceed: () -> Void = { [weak self, weak window] in
                guard let self, let window, self.window === window else { return }
                showInitialScreen(in: window)
            }
            
            let later: () -> Void = {
                UserDefaults.standard.set(version, forKey: Self.skippedRecommendationKey)
                proceed()
            }
            
            let update: () -> Void = {
                Self.openAppStore()
                proceed()
            }
            
            let modal = ActionPrimaryModal(
                title: "새로운 버전이 나왔어요",
                description: "업데이트하고 더 편해진\n루티를 만나보세요.",
                leftButtonTitle: "나중에",
                rightButtonTitle: "업데이트",
                primaryButtonTitleColor: .white,
                dismissOnBackgroundTap: false,
                leftButtonAction: later,
                rightButtonAction: update
            )
            
            loadingViewController.present(modal, animated: true)
        }
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
        guard let window, !(window.rootViewController is StartupLoadingViewController) else { return }

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

private final class StartupLoadingViewController: UIViewController {

    var onFirstAppearance: (() -> Void)?
    private let activityIndicator = UIActivityIndicatorView(style: .medium)

    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = .grey_900
        activityIndicator.color = .white
        activityIndicator.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(activityIndicator)
        NSLayoutConstraint.activate([
            activityIndicator.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            activityIndicator.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        ])
        activityIndicator.startAnimating()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        let onFirstAppearance = onFirstAppearance
        self.onFirstAppearance = nil
        onFirstAppearance?()
    }

    func stopLoading() {
        activityIndicator.stopAnimating()
    }
}
