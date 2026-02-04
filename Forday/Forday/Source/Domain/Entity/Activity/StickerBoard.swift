//
//  StickerBoard.swift
//  Forday
//
//  Created by Subeen on 1/23/26.
//

import Foundation

/// Domain model for sticker board
/// Guaranteed to have valid, non-optional values
struct StickerBoard: Sendable {
    let hobbyId: Int
    let durationSet: Bool
    let activityRecordedToday: Bool
    let currentPage: Int
    let totalPage: Int
    let pageSize: Int
    let totalStickerNum: Int
    let hasPrevious: Bool
    let hasNext: Bool
    let stickers: [StickerBoardItem]
}

struct StickerBoardItem {
    let activityRecordId: Int
    let sticker: String?
    let deleted: Bool

    /// Converts the sticker filename string to a StickerType enum
    /// Returns nil if deleted or sticker is nil
    var stickerType: StickerType? {
        guard !deleted, let sticker = sticker else { return nil }
        return StickerType(fileName: sticker)
    }
}

/// Represents the state when no hobby is in progress
struct EmptyStickerBoard {
    let message: String

    static var noHobbyInProgress: EmptyStickerBoard {
        EmptyStickerBoard(message: "진행 중인 취미가 없습니다")
    }
}
