//
//  MetadataResponse.swift
//  Forday
//
//  Created by Subeen on 1/15/26.
//

import Foundation

extension DTO {

    struct MetadataResponse: BaseResponse {
        let status: Int
        let success: Bool
        let data: Metadata
    }

    struct Metadata: Codable {
        let appVersion: String
        let hobbyInfos: [HobbyInfo]
    }
}

extension DTO.MetadataResponse {
    func toDomain() -> AppMetadata {
        return AppMetadata(
            appVersion: data.appVersion,
            hobbyCards: data.hobbyInfos.compactMap { $0.toDomain() }
        )
    }
}
