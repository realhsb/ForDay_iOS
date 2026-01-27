//
//  MyActivitiesResult.swift
//  Forday
//
//  Created by Subeen on 1/23/26.
//

import Foundation

struct MyActivitiesResult {
    let totalFeedCount: Int
    let lastRecordId: Int?
    let feedList: [FeedItem]

    init(totalFeedCount: Int, lastRecordId: Int?, feedList: [FeedItem]) {
        self.totalFeedCount = totalFeedCount
        self.lastRecordId = lastRecordId
        self.feedList = feedList
    }
}
