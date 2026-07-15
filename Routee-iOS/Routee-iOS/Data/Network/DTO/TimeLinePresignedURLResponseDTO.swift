//
//  TimeLinePresignedURLResponseDTO.swift
//  Routee-iOS
//
//  Created by LEESANGYUP on 7/15/26.
//

import Foundation

struct TimeLinePresignedURLResponseDTO: Decodable, Sendable {
    let presignedUrl: String
    let objectKey: String
}

extension TimeLinePresignedURLResponseDTO {
    func toImagePresignedURLModel() -> ImagePresignedURLModel {
        ImagePresignedURLModel(presignedURL: presignedUrl, objectKey: objectKey)
    }
}
