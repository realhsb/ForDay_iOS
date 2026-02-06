//
//  HobbyInfo.swift
//  Forday
//
//  Created by Subeen on 1/28/26.
//

import Foundation

extension DTO {
    struct HobbyInfo: Codable {
        let hobbyInfoId: Int
        let hobbyName: String
        let hobbyDescription: String
        let imageCode: String
    }
}

extension DTO.HobbyInfo {
    func toDomain() -> HobbyCard? {
        // API imageCode 형식: "drawing.png" → HobbyImageAsset
        let imageAsset = HobbyImageAsset(fromApiImageCode: imageCode) ?? .default

        return HobbyCard(
            id: hobbyInfoId,
            name: hobbyName,
            description: hobbyDescription,
            imageAsset: imageAsset
        )
    }
}
