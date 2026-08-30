//
//  MemberRepository.swift
//  Routee-iOS
//
//  Created by LEESANGYUP on 7/13/26.
//

import Foundation

protocol MemberRepository {
    func register(nickname: String, identityToken: String, provider: LoginPlatform) async throws
    func withdraw() async throws
    func getProfile() async throws -> ProfileModel
    func getMemberProfile() async throws -> MemberProfileModel
    func updateNickname(_ nickname: String) async throws -> String
    func profileImagePresignedURL(fileName: String) async throws -> ImagePresignedURLModel
    func uploadProfileImage(presignedURL: String, imageData: Data) async throws
    func updateProfileImage(objectKey: String) async throws -> String
    func updateDefaultProfileImage() async throws
}

struct DefaultMemberRepository: MemberRepository {
    private let service: NetworkService
    private let keychainService: KeychainService

    init(
        service: NetworkService = DefaultNetworkService(),
        keychainService: KeychainService = DefaultKeychainService()
    ) {
        self.service = service
        self.keychainService = keychainService
    }
    
    func register(nickname: String, identityToken: String, provider: LoginPlatform) async throws {
        let dto = RegisterRequestDTO(
            nickname: nickname,
            idToken: identityToken,
            provider: provider.mixpanelKey
        )
        
        let endPoint = MemberAPI.register(
            header: .basic,
            requestDTO: dto
        )
        
        try await service.requestEmpty(endPoint)
    }
    
    func withdraw() async throws {
        let accessToken = keychainService.read(.accessToken)
        let refreshToken = keychainService.read(.refreshToken)

        guard !accessToken.isEmpty, !refreshToken.isEmpty else {
            throw RouteeError.noData
        }

        let requestDTO = WithdrawRequestDTO(refreshToken: refreshToken)
        let endPoint = MemberAPI.withdraw(
            header: .withAuth(accessToken: accessToken),
            requestDTO: requestDTO
        )
        try await service.requestEmpty(endPoint)
        
        KeyType.allCases.forEach {
            keychainService.delete($0)
        }
    }

    func getProfile() async throws -> ProfileModel {
        let accessToken = keychainService.read(.accessToken)

        guard !accessToken.isEmpty else {
            throw RouteeError.noData
        }

        let endPoint = MemberAPI.getProfile(
            header: .withAuthTimeZone(
                accessToken: accessToken,
                timeZone: TimeZone.current.identifier
            )
        )

        let response = try await service.request(
            endPoint,
            decodingType: ProfileResponseDTO.self
        )

        return response.toModel()
    }

    func getMemberProfile() async throws -> MemberProfileModel {
        let accessToken = keychainService.read(.accessToken)

        guard !accessToken.isEmpty else {
            throw RouteeError.noData
        }

        let endPoint = MemberAPI.getMemberProfile(
            header: .withAuth(accessToken: accessToken)
        )

        let response = try await service.request(
            endPoint,
            decodingType: MemberProfileResponseDTO.self
        )

        return response.toModel()
    }

    func updateNickname(_ nickname: String) async throws -> String {
        let accessToken = keychainService.read(.accessToken)

        guard !accessToken.isEmpty else {
            throw RouteeError.noData
        }

        let requestDTO = UpdateNicknameRequestDTO(nickname: nickname)
        let endPoint = MemberAPI.updateNickname(
            header: .withAuth(accessToken: accessToken),
            requestDTO: requestDTO
        )

        let response = try await service.request(
            endPoint,
            decodingType: UpdateNicknameResponseDTO.self
        )

        return response.nickname
    }

    func profileImagePresignedURL(fileName: String) async throws -> ImagePresignedURLModel {
        let accessToken = keychainService.read(.accessToken)

        guard !accessToken.isEmpty else {
            throw RouteeError.noData
        }

        let requestDTO = ProfileImagePresignedURLRequestDTO(fileName: fileName)
        let endPoint = MemberAPI.profileImagePresignedURL(
            header: .withAuth(accessToken: accessToken),
            requestDTO: requestDTO
        )

        let response = try await service.request(
            endPoint,
            decodingType: ProfileImagePresignedURLResponseDTO.self
        )

        return response.toImagePresignedURLModel()
    }

    func uploadProfileImage(presignedURL: String, imageData: Data) async throws {
        try await service.presignedURLUploadData(imageData, to: presignedURL, contentType: "image/jpeg")
    }

    func updateProfileImage(objectKey: String) async throws -> String {
        let accessToken = keychainService.read(.accessToken)

        guard !accessToken.isEmpty else {
            throw RouteeError.noData
        }

        let requestDTO = UpdateProfileImageRequestDTO(objectKey: objectKey)
        let endPoint = MemberAPI.updateProfileImage(
            header: .withAuth(accessToken: accessToken),
            requestDTO: requestDTO
        )

        let response = try await service.request(
            endPoint,
            decodingType: UpdateProfileImageResponseDTO.self
        )

        return response.profileImageUrl
    }

    func updateDefaultProfileImage() async throws {
        let accessToken = keychainService.read(.accessToken)

        guard !accessToken.isEmpty else {
            throw RouteeError.noData
        }

        let endPoint = MemberAPI.updateDefaultProfileImage(
            header: .withAuth(accessToken: accessToken)
        )

        try await service.requestEmpty(endPoint)
    }
}
