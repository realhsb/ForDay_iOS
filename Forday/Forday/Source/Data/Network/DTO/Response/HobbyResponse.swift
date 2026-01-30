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
        let hobbyInfos: [HobbyInfo]
    }
}

extension DTO.HobbyData {
    func toDomain() -> [HobbyCard] {
        return hobbyInfos.compactMap { $0.toDomain() }
    }
}
