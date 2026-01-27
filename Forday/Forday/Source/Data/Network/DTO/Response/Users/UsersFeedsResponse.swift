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
    func toDomain() -> FeedResult {
        let feeds = data.feedList.map { $0.toDomain() }

        return FeedResult(totalFeedCount: data.totalFeedCount, lastRecordId: data.lastRecordId, feedList: feeds)
    }
}

extension DTO.FeedItem {
    func toDomain() -> FeedItem {
        return FeedItem(
            recordId: recordId,
            thumbnailImageUrl: thumbnailImageUrl ?? "",
            sticker: sticker,
            memo: nil,
            createdAt: createdAt
        )
    }

    func toMyPageActivity() -> FeedItem {
        return FeedItem(
            recordId: recordId,
            thumbnailImageUrl: thumbnailImageUrl ?? "",
            sticker: sticker,
            memo: nil,
            createdAt: createdAt
        )
    }
}
