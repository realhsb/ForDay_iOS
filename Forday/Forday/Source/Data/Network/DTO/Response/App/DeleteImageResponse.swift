//
//  DeleteImageResponse.swift
//  Forday
//
//  Created by Subeen on 1/21/26.
//

import Foundation

extension DTO {
    struct DeleteImageResponse: BaseResponse {
        let status: Int
        let success: Bool
        let data: DeleteImageData
    }

    struct DeleteImageData: Codable {
        let message: String
    }
}

extension DTO.DeleteImageResponse {
    func toDomain() -> String {
        return data.message
    }
}
