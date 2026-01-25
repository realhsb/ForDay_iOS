//
//  MyActivitiesResult.swift
//  Forday
//
//  Created by Subeen on 1/23/26.
//

import Foundation

struct MyActivitiesResult {
    let activities: [MyPageActivity]
    let hasNext: Bool
    let lastRecordId: Int?
    let currentPage: Int  // Deprecated: only for backward compatibility
    let totalPages: Int   // Deprecated: only for backward compatibility

    init(activities: [MyPageActivity], hasNext: Bool, lastRecordId: Int?, currentPage: Int = 0, totalPages: Int = 0) {
        self.activities = activities
        self.hasNext = hasNext
        self.lastRecordId = lastRecordId
        self.currentPage = currentPage
        self.totalPages = totalPages
    }
}
