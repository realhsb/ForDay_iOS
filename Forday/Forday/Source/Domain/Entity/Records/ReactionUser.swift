//
//  ReactionUser.swift
//  Forday
//
//  Created by Subeen on 1/31/26.
//

import Foundation

struct ReactionUser {
    let userId: String
    let nickname: String
    let profileImageUrl: String?
    let reactedAt: String
    let newReactionUser: Bool
}

// MARK: - Preview

#if DEBUG
extension ReactionUser {
    static var preview: ReactionUser {
        ReactionUser(
            userId: "1",
            nickname: "러너",
            profileImageUrl: nil,
            reactedAt: "1시간 전",
            newReactionUser: false
        )
    }

    static var previewWithImage: ReactionUser {
        ReactionUser(
            userId: "2",
            nickname: "달리기",
            profileImageUrl: "https://picsum.photos/200/200",
            reactedAt: "2시간 전",
            newReactionUser: false
        )
    }

    static var previewNew: ReactionUser {
        ReactionUser(
            userId: "3",
            nickname: "요가러버",
            profileImageUrl: "https://picsum.photos/200/201",
            reactedAt: "방금 전",
            newReactionUser: true
        )
    }

    static var previewList: [ReactionUser] {
        [
            ReactionUser(
                userId: "1",
                nickname: "러너",
                profileImageUrl: "https://picsum.photos/200/200",
                reactedAt: "1시간 전",
                newReactionUser: true
            ),
            ReactionUser(
                userId: "2",
                nickname: "달리기",
                profileImageUrl: nil,
                reactedAt: "2시간 전",
                newReactionUser: false
            ),
            ReactionUser(
                userId: "3",
                nickname: "요가러버",
                profileImageUrl: "https://picsum.photos/200/201",
                reactedAt: "3시간 전",
                newReactionUser: false
            ),
            ReactionUser(
                userId: "4",
                nickname: "헬스맨",
                profileImageUrl: "https://picsum.photos/200/202",
                reactedAt: "5시간 전",
                newReactionUser: true
            ),
            ReactionUser(
                userId: "5",
                nickname: "등산왕",
                profileImageUrl: nil,
                reactedAt: "1일 전",
                newReactionUser: false
            )
        ]
    }
}
#endif
