//
//  MemberSummaryViewModel.swift
//  Routee-iOS
//

import Foundation

@MainActor
final class MemberSummaryViewModel {

    // MARK: - Properties

    private let memberRepository: MemberRepository

    // MARK: - Initializer

    init(memberRepository: MemberRepository = DefaultMemberRepository()) {
        self.memberRepository = memberRepository
    }

    // MARK: - Public Methods

    func fetchSummary() async throws -> MemberSummaryModel {
        try await memberRepository.getMemberSummary()
    }
}
