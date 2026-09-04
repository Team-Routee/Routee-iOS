//
//  OnboardingViewModel.swift
//  Routee-iOS
//
//  Created by LEESANGYUP on 7/7/26.
//

import Foundation

final class OnboardingViewModel {
    private let authRepository: AuthRepository
    private let memberRepository: MemberRepository

    init(
        authRepository: AuthRepository = DefaultAuthRepository(),
        memberRepository: MemberRepository = DefaultMemberRepository()
    ) {
        self.authRepository = authRepository
        self.memberRepository = memberRepository
    }

    func registerAndLogin(
        platform: LoginPlatform,
        identityToken: String,
        appleUserID: String,
        nickname: String
    ) async throws {
        try await memberRepository.register(
            nickname: nickname,
            identityToken: identityToken,
            provider: platform
        )

        AnalyticsTracker.track(
            .signUpCompleted,
            properties: ["login_provider": platform.mixpanelKey]
        )

        try await authRepository.login(
            platform: platform,
            identityToken: identityToken,
            appleUserID: appleUserID
        )

        AnalyticsTracker.track(
            .onboardingCompleted,
            properties: ["login_provider": platform.mixpanelKey]
        )
    }
}
