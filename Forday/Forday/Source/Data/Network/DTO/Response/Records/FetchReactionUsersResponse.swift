//
//  FetchReactionUsersResponse.swift
//  Forday
//
//  Created by Subeen on 1/31/26.
//

import Foundation

extension DTO {
    struct FetchReactionUsersResponse: BaseResponse {
        let status: Int
        let success: Bool
        let data: FetchReactionUsersData
    }

    struct FetchReactionUsersData: Codable {
        let reactionType: String
        let reactionUsers: [ReactionUserDTO]
        let hasNext: Bool
        let lastUserId: String?
    }

    struct ReactionUserDTO: Codable {
        let userId: String
        let nickname: String
        let profileImageUrl: String?
        let reactedAt: String
        let newReactionUser: Bool
    }
}

// MARK: - Domain Mapping

extension DTO.FetchReactionUsersResponse {
    func toDomain() -> FetchReactionUsersResult {
        return FetchReactionUsersResult(
            reactionType: ReactionType(rawValue: data.reactionType) ?? .awesome,
            reactionUsers: data.reactionUsers.map { $0.toDomain() },
            hasNext: data.hasNext,
            lastUserId: data.lastUserId
        )
    }
}

extension DTO.ReactionUserDTO {
    func toDomain() -> ReactionUser {
        return ReactionUser(
            userId: userId,
            nickname: nickname,
            profileImageUrl: profileImageUrl,
            reactedAt: reactedAt,
            newReactionUser: newReactionUser
        )
    }
}
