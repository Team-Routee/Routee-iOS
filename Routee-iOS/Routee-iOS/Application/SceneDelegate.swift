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
    private let keychainService = DefaultKeychainService()
    private var maintenanceFetch: Task<Void, Never>?
    private var maintenanceWait: Task<Void, Never>?
    private var observesNotifications = false
    
    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        guard let windowScene = (scene as? UIWindowScene) else { return }
        let window = UIWindow(windowScene: windowScene)
        self.window = window

#if DEVELOPMENT
        if FirebaseApp.app() != nil {
            let remoteConfig = RemoteConfig.remoteConfig()
            let settings = RemoteConfigSettings()
            settings.minimumFetchInterval = 0
            remoteConfig.configSettings = settings
            remoteConfig.setDefaults([Self.maintenanceKey: NSNumber(value: false)])

            let loadingViewController = StartupLoadingViewController()
            loadingViewController.onFirstAppearance = { [weak self] in
                self?.checkMaintenance(using: remoteConfig, maximumWait: .seconds(1))
            }
            window.rootViewController = loadingViewController
            window.makeKeyAndVisible()
            return
        }
#endif

        showInitialScreen(in: window)
    }

    func sceneDidDisconnect(_ scene: UIScene) {
        maintenanceFetch?.cancel()
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
    
    private func checkMaintenance(using remoteConfig: RemoteConfig, maximumWait: Duration) {
        guard maintenanceWait == nil,
              let loadingViewController = window?.rootViewController as? StartupLoadingViewController else { return }

        let modal = loadingViewController.presentedViewController as? ActionPrimaryModal
        modal?.setActionsEnabled(false)

        if maintenanceFetch == nil {
            maintenanceFetch = Task { [weak self] in
                do {
                    _ = try await remoteConfig.fetchAndActivate()
                } catch {
                    RouteeLogger.debug("Remote Config fetch failed (code \((error as NSError).code))")
                }

                guard !Task.isCancelled, let self else { return }
                maintenanceFetch = nil
                finishMaintenanceCheck(using: remoteConfig)
            }
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
                self?.checkMaintenance(using: remoteConfig, maximumWait: .seconds(3))
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
                showInitialScreen(in: window)
            }
        } else {
            showInitialScreen(in: window)
        }
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
