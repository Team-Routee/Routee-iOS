//
//  ProfileChangeViewModel.swift
//  Routee-iOS
//
//  Created by 초긍정행운의포춘쿠키 on 8/26/26.
//

import Foundation

@MainActor
final class ProfileChangeViewModel {

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
