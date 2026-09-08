//
//  ExternalURLHandler.swift
//  Routee-iOS
//
//  Created by 초긍정행운의포춘쿠키 on 8/26/26.
//

import UIKit

@MainActor
enum ExternalURLHandler {

    private static let kakaoChannelURL = "http://pf.kakao.com/_ExkxgSX"
    private static let instagramURL = "https://www.instagram.com/routee_official/?hl=ko"
    private static let termsOfServiceURL = "https://acoustic-boat-573.notion.site/3d57d9beca1d8037bafdfb57414e9c65"
    private static let privacyPolicyURL = "https://acoustic-boat-573.notion.site/3d57d9beca1d800cbacdf28bf6006257"
    private static let locationTermsURL = "https://acoustic-boat-573.notion.site/3d57d9beca1d80e1b6d4e7e4750b94e6"

    static func openKakaoChannel() {
        openURL(kakaoChannelURL)
    }

    static func openInstagram() {
        openURL(instagramURL)
    }

    static func openTermsOfService() {
        openURL(termsOfServiceURL)
    }

    static func openPrivacyPolicy() {
        openURL(privacyPolicyURL)
    }

    static func openLocationTerms() {
        openURL(locationTermsURL)
    }

    private static func openURL(_ urlString: String) {
        guard let url = URL(string: urlString) else { return }

        UIApplication.shared.open(url)
    }
}
