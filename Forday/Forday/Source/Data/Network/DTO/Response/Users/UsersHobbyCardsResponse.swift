//
//  UsersHobbyCardsResponse.swift
//  Forday
//
//  Created by Subeen on 1/26/26.
//

extension DTO  {
    struct UsersHobbyCardResponse: BaseResponse {
        let status: Int
        let success: Bool
        let data: UsersHobbyCardData

        struct UsersHobbyCardData: Codable {
            let lastHobbyCardId: Int?
            let hobbyCardList: [UsersHobbyCard]
            let hasNext: Bool
        }

        struct UsersHobbyCard: Codable {
            let hobbyCardId: Int
            let hobbyCardContent: String
            let imageUrl: String
            let createdAt: String
        }
    }
}

// MARK: - Domain Mapping

extension DTO.UsersHobbyCardResponse {
    func toDomain() -> HobbyCardsResult {
        HobbyCardsResult(
            lastCardId: data.lastHobbyCardId,
            cards: data.hobbyCardList.map { $0.toDomain() },
            hasNext: data.hasNext
        )
    }
}

extension DTO.UsersHobbyCardResponse.UsersHobbyCard {
    func toDomain() -> CompletedHobbyCard {
        CompletedHobbyCard(
            cardId: hobbyCardId,
            content: hobbyCardContent,
            imageUrl: imageUrl,
            createdAt: createdAt
        )
    }
}
