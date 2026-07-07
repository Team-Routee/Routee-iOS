//
//  LoginPlatform.swift
//  Routee-iOS
//
//  Created by LEESANGYUP on 7/6/26.
//

import Foundation

enum LoginPlatform {
    case APPLE
}

extension LoginPlatform {
    var mixpanelKey: String {
        switch self {
        case .APPLE:
            "APPLE"
        }
    }
}
