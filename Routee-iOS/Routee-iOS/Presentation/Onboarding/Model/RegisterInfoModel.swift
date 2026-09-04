//
//  RegisterInfoModel.swift
//  Routee-iOS
//
//  Created by LEESANGYUP on 9/4/26.
//

import Foundation

struct RegisterInfoModel: Sendable {
    let nickname: String
    let identityToken: String
    let provider: LoginPlatform
    let agreements: Agreements

    struct Agreements: Sendable {
        let serviceTerms: Bool
        let privacyPolicy: Bool
        let locationServiceTerms: Bool
        let over14: Bool
        let marketingConsent: Bool
    }
}
