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
    let currentPage: Int
    let totalPages: Int
}
