//
//  OnboardingViewModel.swift
//  Routee-iOS
//
//  Created by LEESANGYUP on 7/7/26.
//

import Foundation

final class OnboardingViewModel {
    private let authRepository: AuthRepository

    init(authRepository: AuthRepository = DefaultAuthRepository()) {
        self.authRepository = authRepository
    }

    func appleLogin(
        platform: LoginPlatform,
        identityToken: String,
        nickname: String
    ) async throws {
        try await authRepository.appleLogin(
            platform: platform,
            identityToken: identityToken,
            nickname: nickname
        )
    }
}
