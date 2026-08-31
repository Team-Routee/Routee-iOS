//
//  MemberSummaryResponseDTO.swift
//  Routee-iOS
//
//  Created by 초긍정행운의포춘쿠키 on 8/31/26.
//

import Foundation

struct MemberSummaryResponseDTO: Decodable, Sendable {
    let nickname: String
    let profileImageUrl: String?
    let joinDate: String
    let daysSinceJoining: Int
    let totalActivityCount: Int
}

extension MemberSummaryResponseDTO {
    func toModel() -> MemberSummaryModel {
        MemberSummaryModel(
            nickname: nickname,
            profileImageUrl: profileImageUrl,
            joinDate: joinDate,
            daysSinceJoining: daysSinceJoining,
            totalActivityCount: totalActivityCount
        )
    }
}
