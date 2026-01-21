//
//  CreateActivityRecordResponse.swift
//  Forday
//
//  Created by Subeen on 1/21/26.
//

import Foundation

extension DTO {
    struct CreateActivityRecordResponse: BaseResponse {
        let status: Int
        let success: Bool
        let data: CreateActivityRecordData
    }

    struct CreateActivityRecordData: Codable {
        let message: String
        let hobbyId: Int
        let activityRecordId: Int
        let activityContent: String
        let imageUrl: String?
        let sticker: String
        let memo: String?
        let extensionCheckRequired: Bool
    }
}

extension DTO.CreateActivityRecordResponse {
    func toDomain() -> ActivityRecord {
        return ActivityRecord(
            message: data.message,
            hobbyId: data.hobbyId,
            activityRecordId: data.activityRecordId,
            activityContent: data.activityContent,
            imageUrl: data.imageUrl,
            sticker: data.sticker,
            memo: data.memo,
            extensionCheckRequired: data.extensionCheckRequired
        )
    }
}
