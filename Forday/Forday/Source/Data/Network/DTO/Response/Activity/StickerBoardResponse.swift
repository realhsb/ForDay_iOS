//
//  StickerBoardResponse.swift
//  Forday
//
//  Created by Subeen on 1/23/26.
//

import Foundation

extension DTO {
    /// Pure DTO - no domain mapping logic
    /// Repository will handle nil interpretation and transformation
    struct StickerBoardDTO: Decodable {
        let hobbyId: Int
        let durationSet: Bool
        let activityRecordedToday: Bool
        let currentPage: Int
        let totalPage: Int
        let pageSize: Int
        let totalStickerNum: Int
        let hasPrevious: Bool
        let hasNext: Bool
        let stickers: [StickerDTO]?

        struct StickerDTO: Decodable {
            let activityRecordId: Int?
            let sticker: String?
        }
    }
}
