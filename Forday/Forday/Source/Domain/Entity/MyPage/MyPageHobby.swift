//
//  MyPageHobby.swift
//  Forday
//
//  Created by Subeen on 1/23/26.
//

import Foundation

struct MyPageHobby {
    let hobbyId: Int
    let hobbyName: String
    let hobbyIcon: HobbyImageAsset
    let status: HobbyStatus
    let activityCount: Int

    var isArchived: Bool {
        return status == .archived
    }
}
