//
//  UpdateHobbyResponse.swift
//  Forday
//
//  Created by Subeen on 1/21/26.
//

import Foundation

extension DTO {
    struct UpdateHobbyResponse: BaseResponse {
        let status: Int
        let success: Bool
        let data: UpdateHobbyData
    }

    struct UpdateHobbyData: Codable {
        let message: String
    }
}

extension DTO.UpdateHobbyResponse {
    func toDomain() -> String {
        return data.message
    }
}
