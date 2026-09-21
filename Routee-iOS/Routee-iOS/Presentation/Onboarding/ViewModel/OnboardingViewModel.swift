//
//  OnboardingViewModel.swift
//  Routee-iOS
//
//  Created by LEESANGYUP on 7/7/26.
//

import Foundation

final class OnboardingViewModel {
    private let memberRepository: MemberRepository

    init(memberRepository: MemberRepository = DefaultMemberRepository()) {
        self.memberRepository = memberRepository
    }

    func register(registerInfo: RegisterInfoModel) async throws {
        try await memberRepository.register(registerInfo: registerInfo)

        AnalyticsTracker.track(
            .signUpCompleted,
            properties: ["login_provider": registerInfo.provider.mixpanelKey]
        )

        AnalyticsTracker.track(
            .onboardingCompleted,
            properties: ["login_provider": registerInfo.provider.mixpanelKey]
        )
    }
}
