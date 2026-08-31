//
//  MemberProfileResponseDTO.swift
//  Routee-iOS
//
//  Created by 초긍정행운의포춘쿠키 on 8/31/26.
//

import Foundation

struct MemberProfileResponseDTO: Decodable, Sendable {
    let nickname: String
    let profileImageUrl: String?
}

extension MemberProfileResponseDTO {
    func toModel() -> MemberProfileModel {
        MemberProfileModel(
            nickname: nickname,
            profileImageUrl: profileImageUrl
        )
    }
}
