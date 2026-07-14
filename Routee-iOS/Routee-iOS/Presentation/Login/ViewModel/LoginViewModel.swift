//
//  LoginViewModel.swift
//  Routee-iOS
//
//  Created by LEESANGYUP on 7/14/26.
//

import Foundation

final class LoginViewModel {
    private let authRepository = DefaultAuthRepository()

    func login(platform: LoginPlatform, identityToken: String) async throws {
        try await authRepository.login(
            platform: platform,
            identityToken: identityToken
        )
    }
}
