//
//  UserProfile.swift
//  Forday
//
//  Created by Subeen on 1/23/26.
//

import Foundation

struct UserProfile {
    let userId: Int
    let nickname: String
    let profileImageUrl: String?
    let totalStickerCount: Int
    let inProgressHobbiesCount: Int

    var stickerDisplayText: String {
        return "\(totalStickerCount)개 스티커 수집 중"
    }
}
