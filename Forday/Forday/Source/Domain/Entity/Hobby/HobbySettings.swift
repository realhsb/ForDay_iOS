//
//  HobbySettings.swift
//  Forday
//
//  Created by Subeen on 1/21/26.
//

import Foundation

struct HobbySettings {
    let currentHobbyStatus: HobbyStatus
    let inProgressHobbyCount: Int
    let archivedHobbyCount: Int
    let hobbies: [HobbySetting]
}

struct HobbySetting {
    let hobbyId: Int
    let hobbyName: String
    let hobbyTimeMinutes: Int
    let executionCount: Int
    let goalDays: Int?  // nil means 무제한 (기간 미지정)

    var timeDisplayText: String {
        if hobbyTimeMinutes >= 60 {
            let hours = hobbyTimeMinutes / 60
            return "\(hours)시간"
        } else {
            return "\(hobbyTimeMinutes)분"
        }
    }

    var executionDisplayText: String {
        return "주 \(executionCount)회"
    }

    var goalDaysDisplayText: String {
        if let goalDays = goalDays {
            return "\(goalDays)일"
        } else {
            return "기간 미지정"
        }
    }

    var infoDisplayText: String {
        return "\(timeDisplayText) · \(executionDisplayText) · \(goalDaysDisplayText)"
    }
}
