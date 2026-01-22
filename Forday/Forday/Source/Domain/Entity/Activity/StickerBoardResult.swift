//
//  StickerBoardResult.swift
//  Forday
//
//  Created by Subeen on 1/23/26.
//

import Foundation

enum StickerBoardResult {
    case loaded(StickerBoard)           // 데이터 있음
    case noHobbyInProgress              // data: null (진행 중인 취미 없음)
    case emptyBoard(StickerBoard)       // 취미는 있지만 stickers: []
}
