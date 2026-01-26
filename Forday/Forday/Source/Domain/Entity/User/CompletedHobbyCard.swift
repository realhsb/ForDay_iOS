//
//  CompletedHobbyCard.swift
//  Forday
//
//  Created by Subeen on 1/26/26.
//

import Foundation

/// 66개 스티커를 완료한 취미의 AI 생성 카드
struct CompletedHobbyCard {
    let cardId: Int
    let content: String
    let imageUrl: String
    let createdAt: String
}

/// 완료된 취미 카드 목록 조회 결과 (페이지네이션 포함)
struct HobbyCardsResult {
    let lastCardId: Int?
    let cards: [CompletedHobbyCard]
    let hasNext: Bool
}
