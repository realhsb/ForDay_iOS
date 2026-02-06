//
//  HobbyInfoRecheckResponse.swift
//  Forday
//
//  Created by Subeen on 2/6/26.
//

import Foundation

extension DTO {

    struct HobbyInfoRecheckResponse: BaseResponse {
        let status: Int
        let success: Bool
        let data: HobbyInfoRecheckData
    }

    struct HobbyInfoRecheckData: Codable {
        let hobbyInfo: [HobbyInfo]
    }
}

extension DTO.HobbyInfoRecheckResponse {
    func toDomain() -> [HobbyCard] {
        return data.hobbyInfo.compactMap { $0.toDomain() }
    }
}
