//
//  HomeInfo.swift
//  Forday
//
//  Created by Subeen on 1/17/26.
//

import Foundation

struct HomeInfo {
    let inProgressHobbies: [InProgressHobby]
    let activityPreview: ActivityPreview?
    let aiCallRemaining: Bool
}

struct InProgressHobby {
    let hobbyId: Int
    let hobbyName: String
    let currentHobby: Bool
}

struct ActivityPreview {
    let activityId: Int
    let content: String
    let aiRecommended: Bool
}
