//
//  StickerBoardFallbackProvider.swift
//  Forday
//
//  Created by Subeen on 1/23/26.
//

import Foundation

/// Protocol for providing fallback sticker board data
/// Used when API returns null or fails in DEBUG mode
protocol StickerBoardFallbackProviding {
    func fallbackStickerBoard() -> StickerBoard
}

#if DEBUG
/// Default implementation for DEBUG builds
struct DefaultStickerBoardFallbackProvider: StickerBoardFallbackProviding {
    func fallbackStickerBoard() -> StickerBoard {
        return StickerBoard(
            hobbyId: 0,
            durationSet: true,
            activityRecordedToday: false,
            currentPage: 1,
            totalPage: 1,
            pageSize: 28,
            totalStickerNum: 3,
            hasPrevious: false,
            hasNext: false,
            stickers: [
                StickerBoardItem(activityRecordId: 1, sticker: "🌟"),
                StickerBoardItem(activityRecordId: 2, sticker: "💎"),
                StickerBoardItem(activityRecordId: 3, sticker: "🔥")
            ]
        )
    }
}
#endif
