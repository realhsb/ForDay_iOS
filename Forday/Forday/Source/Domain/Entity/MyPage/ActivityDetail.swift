//
//  ActivityDetail.swift
//  Forday
//
//  Created by Subeen on 1/23/26.
//

import Foundation

struct ActivityDetail {
    let activityRecordId: Int
    let activityId: Int
    let activityContent: String
    let imageUrl: String
    let sticker: String
    let createdAt: String
    let memo: String
    let recordOwner: Bool
    let visibility: String
    let newReaction: ReactionStatus
    let userReaction: ReactionStatus
}
