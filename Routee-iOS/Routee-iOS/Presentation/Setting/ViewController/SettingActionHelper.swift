//
//  SettingActionHelper.swift
//  Routee-iOS
//
//  Created by 초긍정행운의포춘쿠키 on 8/26/26.
//

import UIKit

enum SettingActionHelper {
    static let emailCopiedToastMessage = "이메일이 복사되었습니다."
    
    private static let emailText = "routee.ask@gmail.com"
    private static let kakaoChannelURL = "http://pf.kakao.com/_ExkxgSX"
    private static let instagramURL = "https://www.instagram.com/routee_official/?hl=ko"

    static func copyEmail() {
        UIPasteboard.general.string = emailText
    }
    
    static func openKakaoChannel() {
        openURL(kakaoChannelURL)
    }
    
    static func openInstagram() {
        openURL(instagramURL)
    }

    private static func openURL(_ urlString: String) {
        guard let url = URL(string: urlString) else { return }

        UIApplication.shared.open(url)
    }
}
