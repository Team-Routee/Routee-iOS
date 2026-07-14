//
//  ProfileResponseDTO.swift
//  Routee-iOS
//

import Foundation

struct ProfileResponseDTO: Decodable, Sendable {
    let nickname: String
    let profileImageUrl: String?
    let joinDate: String
    let daysSinceJoining: Int
    let totalActivityCount: Int
}

extension ProfileResponseDTO {
    func toModel() -> ProfileModel {
        ProfileModel(
            nickname: nickname,
            profileImageUrl: profileImageUrl,
            joinDate: joinDate,
            daysSinceJoining: daysSinceJoining,
            totalActivityCount: totalActivityCount
        )
    }
}
