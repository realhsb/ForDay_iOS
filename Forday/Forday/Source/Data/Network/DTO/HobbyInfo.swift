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
        guard let imageAsset = HobbyImageAsset(rawValue: imageCode) else {
            return nil
        }

        return HobbyCard(
            id: hobbyInfoId,
            name: hobbyName,
            description: hobbyDescription,
            imageAsset: imageAsset
        )
    }
}
