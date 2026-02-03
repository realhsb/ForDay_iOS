//
//  MyPageActivity.swift
//  Forday
//
//  Created by Subeen on 1/23/26.
//

import Foundation

struct MyPageActivity {
    let activityRecordId: Int
    let hobbyId: Int
    let hobbyName: String
    let activityContent: String
    let imageUrl: String
    let sticker: String
    let createdDate: String
    let memo: String?

    /// Converts the sticker filename string to a StickerType enum
    var stickerType: StickerType? {
        StickerType(fileName: sticker)
    }
}
