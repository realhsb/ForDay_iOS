//
//  UpdateHobbyCoverResponse.swift
//  Forday
//
//  Created by Subeen on 1/27/26.
//

extension DTO {
    struct UpdateHobbyCoverResponse: BaseResponse {
        let status: Int
        let success: Bool
        let data: UpdateHobbyCoverData

        struct UpdateHobbyCoverData: Codable {
            let message: String
        }
    }
}

// MARK: - Domain Mapping

extension DTO.UpdateHobbyCoverResponse {
    func toDomain() -> UpdateHobbyCoverResult {
        UpdateHobbyCoverResult(message: data.message)
    }
}
