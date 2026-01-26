//
//  UsersFeedsResponse.swift
//  Forday
//
//  Created by Subeen on 1/26/26.
//

extension DTO {
    struct UsersFeedsResponse: BaseResponse {
        let status: Int
        let success: Bool
        let data: UsersFeedsData
    }

    struct UsersFeedsData: Codable {
        let totalFeedCount: Int
        let lastRecordId: Int?
        let feedList: [FeedItem]
        let hasNext: Bool
    }

    struct FeedItem: Codable {
        let recordId: Int
        let thumbnailImageUrl: String?
        let sticker: String
        let createdAt: String
    }
}

// MARK: - Domain Mapping

extension DTO.UsersFeedsResponse {
    func toDomain() -> MyActivitiesResult {
        let activities = data.feedList.map { $0.toDomain() }

        return MyActivitiesResult(
            activities: activities,
            hasNext: data.hasNext,
            lastRecordId: data.lastRecordId
        )
    }
}

extension DTO.FeedItem {
    func toDomain() -> MyPageActivity {
        return MyPageActivity(
            activityRecordId: recordId,
            hobbyId: 0, // Not provided by API
            hobbyName: "", // Not provided by API
            activityContent: "", // Not provided by API
            imageUrl: thumbnailImageUrl ?? "",
            sticker: sticker,
            createdDate: createdAt,
            memo: nil // Not provided by API
        )
    }
}
