//
//  HobbyResponse.swift
//  Forday
//
//  Created by Subeen on 1/12/26.
//

extension DTO {
    
    struct HobbyResponse: BaseResponse {
        let status: Int
        let success: Bool
        let data: HobbyData
    }
    
    struct HobbyData: Codable {
        let appVersion: String
        let hobbyCards: [HobbyCard]
    }
    
    struct HobbyCard: Codable {
        let hobbyCardId: Int
        let hobbyName: String
        let hobbyDescription: String
        let imageCode: String
    }
}

extension DTO.HobbyData {
    func toDomain() -> [HobbyCard] {
        return hobbyCards.compactMap { $0.toDomain() }
    }
}

extension DTO.HobbyCard {
    func toDomain() -> HobbyCard? {
        guard let imageAsset = HobbyImageAsset(rawValue: imageCode) else {
            return nil
        }
        
        return HobbyCard(
            id: hobbyCardId,
            name: hobbyName,
            description: hobbyDescription,
            imageAsset: imageAsset
        )
    }
}
