//
//  ScrapResponse.swift
//  Forday
//
//  Created by Subeen on 2/1/26.
//

import Foundation

extension DTO {
    struct ScrapResponse: BaseResponse {
        let status: Int
        let success: Bool
        let data: ScrapData
    }

    struct ScrapData: Codable {
        let message: String
        let recordId: Int
        let scraped: Bool
    }
}

// MARK: - Domain Mapping

extension DTO.ScrapResponse {
    func toDomain() -> ScrapResult {
        return ScrapResult(
            message: data.message,
            recordId: data.recordId,
            scraped: data.scraped
        )
    }
}
