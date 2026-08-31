//
//  ProfileImagePresignedURLResponseDTO.swift
//  Routee-iOS
//
//  Created by 초긍정행운의포춘쿠키 on 8/30/26.
//

import Foundation

struct ProfileImagePresignedURLResponseDTO: Decodable, Sendable {
    let presignedUrl: String
    let objectKey: String
}

extension ProfileImagePresignedURLResponseDTO {
    func toImagePresignedURLModel() -> ImagePresignedURLModel {
        ImagePresignedURLModel(presignedURL: presignedUrl, objectKey: objectKey)
    }
}
