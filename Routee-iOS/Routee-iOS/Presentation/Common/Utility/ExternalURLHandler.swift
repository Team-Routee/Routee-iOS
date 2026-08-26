//
//  ExternalURLHandler.swift
//  Routee-iOS
//
//  Created by 초긍정행운의포춘쿠키 on 8/26/26.
//

import UIKit

enum ExternalURLHandler {

    private static let kakaoChannelURL = "http://pf.kakao.com/_ExkxgSX"
    private static let instagramURL = "https://www.instagram.com/routee_official/?hl=ko"
    private static let termsOfServiceURL = "https://app.notion.com/p/395999c4e13b80f088a3c6ff365b0177?source=copy_link"
    private static let privacyPolicyURL = "https://app.notion.com/p/395999c4e13b80e38b45c4fe81688642?source=copy_link"
    private static let locationTermsURL = "https://app.notion.com/p/395999c4e13b80ebb999d285fdfaaffd?source=copy_link"

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
