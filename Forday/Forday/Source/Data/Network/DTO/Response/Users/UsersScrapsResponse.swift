//
//  UsersScrapsResponse.swift
//  Forday
//
//  Created by Subeen on 2/1/26.
//

extension DTO {
    struct UsersScrapsResponse: BaseResponse {
        let status: Int
        let success: Bool
        let data: UsersScrapsData
    }

    struct UsersScrapsData: Codable {
        let totalFeedCount: Int
        let lastRecordId: Int?
        let feedList: [FeedItem]
    }
}

// MARK: - Domain Mapping

extension DTO.UsersScrapsResponse {
    func toDomain(requestedSize: Int) -> FeedResult {
        let feeds = data.feedList.map { $0.toDomain() }

        // Calculate hasNext: if received count < requested size, no more data
        let hasNext = feeds.count >= requestedSize

        return FeedResult(
            totalFeedCount: data.totalFeedCount,
            lastRecordId: data.lastRecordId,
            feedList: feeds,
            hasNext: hasNext
        )
    }
}
