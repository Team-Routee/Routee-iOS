//
//  SettingViewModel.swift
//  Routee-iOS
//
//  Created by LEESANGYUP on 7/13/26.
//

import Foundation

final class SettingViewModel {
    private let memberRepository: MemberRepository

    init(memberRepository: MemberRepository = DefaultMemberRepository()) {
        self.memberRepository = memberRepository
    }
    
    func register(nickname: String, identityToken: String, provider: LoginPlatform) async throws {
        try await memberRepository.register(
            nickname: nickname,
            identityToken: identityToken,
            provider: provider
        )
    }
    
    func withdraw(refreshToken: String) async throws {
        try await memberRepository.withdraw(refreshToken: refreshToken)
    }
}
