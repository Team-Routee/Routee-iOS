//
//  AppDelegate.swift
//  Routee-iOS
//
//  Created by LEESANGYUP on 6/22/26.
//

import UIKit

import Mixpanel

@main
class AppDelegate: UIResponder, UIApplicationDelegate {
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        let token = ConfigManager.mixpanelToken

            guard !token.isEmpty else {
                RouteeLogger.error(RouteeError.configError)
                return true
            }

            Mixpanel.initialize(
                token: token,
                trackAutomaticEvents: false
            )

        #if DEVELOPMENT
            let mixpanel = Mixpanel.mainInstance()
            mixpanel.loggingEnabled = true
            mixpanel.track(event: "debug_mixpanel_connected")
            mixpanel.flush()
        #endif

            return true
    }

    // MARK: UISceneSession Lifecycle

    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        // Called when a new scene session is being created.
        // Use this method to select a configuration to create the new scene with.
        return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
    }

    func application(_ application: UIApplication, didDiscardSceneSessions sceneSessions: Set<UISceneSession>) {
        // Called when the user discards a scene session.
        // If any sessions were discarded while the application was not running, this will be called shortly after application:didFinishLaunchingWithOptions.
        // Use this method to release any resources that were specific to the discarded scenes, as they will not return.
    }


}

