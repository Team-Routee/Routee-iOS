//
//  SettingViewModel.swift
//  Routee-iOS
//
//  Created by LEESANGYUP on 7/13/26.
//

import Foundation

final class SettingViewModel {
    private let memberRepository: MemberRepository
    private let authRepository: AuthRepository

    init(
        memberRepository: MemberRepository = DefaultMemberRepository(),
        authRepository: AuthRepository = DefaultAuthRepository()
    ) {
        self.memberRepository = memberRepository
        self.authRepository = authRepository
    }
    
    func withdraw() async throws {
        let recoveryStore = WorkoutRecoveryStore(accountId: DefaultKeychainService().read(.appleUserID))
        try await memberRepository.withdraw()
        clearWorkoutRecovery(recoveryStore)
    }

    func logout() async throws {
        try await authRepository.logout()
    }

    private func clearWorkoutRecovery(_ recoveryStore: WorkoutRecoveryStore?) {
        do {
            try recoveryStore?.clear()
        } catch {
            RouteeLogger.error(error)
        }
    }
}
