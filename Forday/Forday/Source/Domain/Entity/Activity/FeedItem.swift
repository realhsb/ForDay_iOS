//
//  FeedItem.swift
//  Forday
//
//  Created by Subeen on 1/27/26.
//

import Foundation


struct FeedResult {
    let totalFeedCount: Int
    let lastRecordId: Int?
    let feedList: [FeedItem]
}

struct FeedItem {
    let recordId: Int
    let thumbnailImageUrl: String
    let sticker: String
    let memo: String?
    let createdAt: String
}
