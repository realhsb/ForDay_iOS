//
//  StickerBoardResponse.swift
//  Forday
//
//  Created by Subeen on 1/23/26.
//

import Foundation

extension DTO {
    struct StickerBoardResponse: Decodable {
        let status: Int
        let success: Bool
        let data: StickerBoardData?
    }

    struct StickerBoardData: Decodable {
        let hobbyId: Int
        let durationSet: Bool
        let activityRecordedToday: Bool
        let currentPage: Int
        let totalPage: Int
        let pageSize: Int
        let totalStickerNum: Int
        let hasPrevious: Bool
        let hasNext: Bool
        let stickers: [StickerItem]
    }

    struct StickerItem: Decodable {
        let activityRecordId: Int
        let sticker: String
    }
}

// MARK: - Domain Mapping

extension DTO.StickerBoardResponse {
    func toDomain() -> StickerBoardResult {
        guard let data = data else {
            return .noHobbyInProgress
        }

        if data.stickers.isEmpty {
            let board = StickerBoard(
                hobbyId: data.hobbyId,
                durationSet: data.durationSet,
                activityRecordedToday: data.activityRecordedToday,
                currentPage: data.currentPage,
                totalPage: data.totalPage,
                pageSize: data.pageSize,
                totalStickerNum: data.totalStickerNum,
                hasPrevious: data.hasPrevious,
                hasNext: data.hasNext,
                stickers: []
            )
            return .emptyBoard(board)
        }

        let stickerItems = data.stickers.map { item in
            StickerBoardItem(
                activityRecordId: item.activityRecordId,
                sticker: item.sticker
            )
        }

        let board = StickerBoard(
            hobbyId: data.hobbyId,
            durationSet: data.durationSet,
            activityRecordedToday: data.activityRecordedToday,
            currentPage: data.currentPage,
            totalPage: data.totalPage,
            pageSize: data.pageSize,
            totalStickerNum: data.totalStickerNum,
            hasPrevious: data.hasPrevious,
            hasNext: data.hasNext,
            stickers: stickerItems
        )

        return .loaded(board)
    }
}
