//
//  ActivityDropdownListResponse.swift
//  Forday
//
//  Created by Subeen on 1/20/26.
//

import Foundation

extension DTO {
    struct ActivityDropdownListResponse: BaseResponse {
        let status: Int
        let success: Bool
        let data: ActivityDropdownListData
    }

    struct ActivityDropdownListData: Codable {
        let activities: [ActivityDropdownData]
    }

    struct ActivityDropdownData: Codable {
        let activityId: Int
        let content: String
        let aiRecommended: Bool
    }
}

// MARK: - BaseResponse

extension DTO.ActivityDropdownListResponse {
    func toDomain() -> [Activity] {
        return data.activities.map { $0.toDomain() }
    }
}

extension DTO.ActivityDropdownData {
    func toDomain() -> Activity {
        return Activity(
            activityId: activityId,
            content: content,
            aiRecommended: aiRecommended,
            deletable: true,
            collectedStickerNum: nil
        )
    }
}
