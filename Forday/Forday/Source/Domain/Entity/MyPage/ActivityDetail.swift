//
//  ActivityDetail.swift
//  Forday
//
//  Created by Subeen on 1/23/26.
//

import Foundation

struct ActivityDetail {
    let activityRecordId: Int
    let hobbyId: Int
    let activityId: Int
    let activityContent: String
    let imageUrl: String
    let sticker: String
    let createdAt: String
    let memo: String
    let recordOwner: Bool
    let scraped: Bool
    let userInfo: ActivityDetailUserInfo?
    let visibility: String
    let newReaction: ReactionStatus
    let userReaction: ReactionStatus
}

struct ActivityDetailUserInfo {
    let userId: Int
    let nickname: String
    let profileImageUrl: String?
}
