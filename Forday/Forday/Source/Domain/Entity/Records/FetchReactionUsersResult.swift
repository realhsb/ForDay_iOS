//
//  FetchReactionUsersResult.swift
//  Forday
//
//  Created by Subeen on 1/31/26.
//

import Foundation

struct FetchReactionUsersResult {
    let reactionType: ReactionType
    let reactionUsers: [ReactionUser]
    let hasNext: Bool
    let lastUserId: String?
}
