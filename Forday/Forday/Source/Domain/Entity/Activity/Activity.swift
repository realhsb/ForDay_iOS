//
//  Activity.swift
//  Forday
//
//  Created by Subeen on 1/16/26.
//


import Foundation

struct Activity {
    let activityId: Int
    let content: String
    let aiRecommended: Bool
    let deletable: Bool
    let collectedStickerNum: Int
}

// MARK: - Preview Data

#if DEBUG
extension Activity {
    static let preview = Activity(
        activityId: 1,
        content: "30분 드로잉",
        aiRecommended: true,
        deletable: false,
        collectedStickerNum: 12
    )

    static let previewDeletable = Activity(
        activityId: 2,
        content: "스케치북 펼치기",
        aiRecommended: false,
        deletable: true,
        collectedStickerNum: 8
    )

    static let previewAIDeletable = Activity(
        activityId: 3,
        content: "유튜브 강의 보기",
        aiRecommended: true,
        deletable: true,
        collectedStickerNum: 5
    )

    static let previewList: [Activity] = [
        Activity(activityId: 1, content: "30분 드로잉", aiRecommended: true, deletable: false, collectedStickerNum: 12),
        Activity(activityId: 2, content: "스케치북 펼치기", aiRecommended: false, deletable: true, collectedStickerNum: 8),
        Activity(activityId: 3, content: "유튜브 강의 보기", aiRecommended: true, deletable: false, collectedStickerNum: 5),
        Activity(activityId: 4, content: "크로키 연습", aiRecommended: false, deletable: true, collectedStickerNum: 3),
        Activity(activityId: 5, content: "색연필 드로잉", aiRecommended: true, deletable: true, collectedStickerNum: 0),
    ]
}
#endif
