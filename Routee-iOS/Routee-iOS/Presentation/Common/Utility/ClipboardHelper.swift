//
//  ClipboardHelper.swift
//  Routee-iOS
//
//  Created by 초긍정행운의포춘쿠키 on 8/26/26.
//

import UIKit

enum ClipboardHelper {

    static let routeeEmail = "routee.ask@gmail.com"

    static func copy(_ text: String) {
        UIPasteboard.general.string = text
    }
}
