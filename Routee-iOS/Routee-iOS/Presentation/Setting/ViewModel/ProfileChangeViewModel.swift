//
//  ProfileChangeViewModel.swift
//  Routee-iOS
//
//  Created by 초긍정행운의포춘쿠키 on 8/26/26.
//

import Foundation
import UIKit

@MainActor
final class ProfileChangeViewModel {

    // MARK: - Properties

    private let memberRepository: MemberRepository

    // MARK: - Initializer

    init(memberRepository: MemberRepository = DefaultMemberRepository()) {
        self.memberRepository = memberRepository
    }

    // MARK: - Public Methods

    func fetchProfile() async throws -> MemberProfileModel {
        try await memberRepository.getMemberProfile()
    }

    func updateProfile(
        nickname: String,
        hasNicknameChanged: Bool,
        shouldApplyDefaultProfileImage: Bool,
        profileImage: UIImage?
    ) async throws {
        if hasNicknameChanged {
            _ = try await memberRepository.updateNickname(nickname)
        }

        if shouldApplyDefaultProfileImage {
            try await memberRepository.updateDefaultProfileImage()
            return
        }

        guard let profileImage else { return }

        guard let imageData = await Self.encodeProfileImage(profileImage) else {
            throw RouteeError.noData
        }

        let presigned = try await memberRepository.profileImagePresignedURL(
            fileName: "\(UUID().uuidString).jpg"
        )

        try await memberRepository.uploadProfileImage(
            presignedURL: presigned.presignedURL,
            imageData: imageData
        )

        _ = try await memberRepository.updateProfileImage(objectKey: presigned.objectKey)
    }

    private nonisolated static func encodeProfileImage(_ image: UIImage) async -> Data? {
        await Task.detached(priority: .userInitiated) {
            image.jpegData(compressionQuality: 1)
        }.value
    }
}
