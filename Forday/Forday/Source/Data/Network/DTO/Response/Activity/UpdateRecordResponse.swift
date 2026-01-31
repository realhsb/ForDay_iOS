//
//  UpdateRecordResponse.swift
//  Forday
//
//  Created by Subeen on 1/31/26.
//

import Foundation

extension DTO {
    struct UpdateRecordResponse: BaseResponse {
        let status: Int
        let success: Bool
        let data: UpdateRecordData
    }

    struct UpdateRecordData: Codable {
        let message: String
        let activityId: Int
        let activityContent: String
        let sticker: String
        let memo: String?
        let imageUrl: String?
        let visibility: String
    }
}

extension DTO.UpdateRecordResponse {
    func toDomain() -> UpdateRecordResult {
        return UpdateRecordResult(
            message: data.message,
            activityId: data.activityId,
            activityContent: data.activityContent,
            sticker: data.sticker,
            memo: data.memo,
            imageUrl: data.imageUrl,
            visibility: data.visibility
        )
    }
}
