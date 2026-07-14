//
//  SceneDelegate.swift
//  Routee-iOS
//
//  Created by LEESANGYUP on 6/22/26.
//

import AuthenticationServices
import UIKit

class SceneDelegate: UIResponder, UIWindowSceneDelegate {
    
    var window: UIWindow?
    private let keychainService = DefaultKeychainService()
    
    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        guard let windowScene = (scene as? UIWindowScene) else { return }
        let window = UIWindow(windowScene: windowScene)
        
        if keychainService.read(.refreshToken).isEmpty {
            let viewController = LoginViewController()
            let navigationViewController = UINavigationController(rootViewController: viewController)
            navigationViewController.navigationBar.isHidden = true
            window.rootViewController = navigationViewController
        } else {
            window.rootViewController = TabBarViewController()
        }
        
        self.window = window
        window.makeKeyAndVisible()
        
        addNotificationObserver()
        checkAppleCredentialState()
    }
    
    func sceneDidDisconnect(_ scene: UIScene) {
        // Called as the scene is being released by the system.
        // This occurs shortly after the scene enters the background, or when its session is discarded.
        // Release any resources associated with this scene that can be re-created the next time the scene connects.
        // The scene may re-connect later, as its session was not necessarily discarded (see `application:didDiscardSceneSessions` instead).
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
    
    private func addNotificationObserver() {
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(navigateLoginViewController),
            name: .navigateLoginViewController,
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
    private func navigateLoginViewController() {
        let loginViewController = LoginViewController()
        let navigationController = UINavigationController(
            rootViewController: loginViewController
        )
        navigationController.navigationBar.isHidden = true
        window?.rootViewController = navigationController
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

