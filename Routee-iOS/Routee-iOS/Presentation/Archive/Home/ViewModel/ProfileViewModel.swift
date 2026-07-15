//
//  ProfileViewModel.swift
//  Routee-iOS
//

import Foundation

@MainActor
final class ProfileViewModel {

    // MARK: - Properties

    private let memberRepository: MemberRepository

    // MARK: - Initializer

    init(memberRepository: MemberRepository = DefaultMemberRepository()) {
        self.memberRepository = memberRepository
    }

    // MARK: - Public Methods

    func fetchProfile() async throws -> ProfileModel {
        try await memberRepository.getProfile()
    }
}
