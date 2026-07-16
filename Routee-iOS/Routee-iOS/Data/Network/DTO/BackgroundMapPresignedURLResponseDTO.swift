//
//  BackgroundMapPresignedURLResponseDTO.swift
//  Routee-iOS
//
//  Created by LEESANGYUP on 7/16/26.
//

import Foundation

struct BackgroundMapPresignedURLResponseDTO: Decodable, Sendable {
    let presignedUrl: String
    let objectKey: String
}

extension BackgroundMapPresignedURLResponseDTO {
    func toImagePresignedURLModel() -> ImagePresignedURLModel {
        ImagePresignedURLModel(presignedURL: presignedUrl, objectKey: objectKey)
    }
}
