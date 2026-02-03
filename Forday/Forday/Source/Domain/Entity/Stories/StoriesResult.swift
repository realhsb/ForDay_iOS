//
//  StoriesResult.swift
//  Forday
//
//  Created by Subeen on 2/1/26.
//

import Foundation

struct StoriesResult {
    let hobbyInfoId: Int
    let hobbyId: Int
    let hobbyName: String
    let stories: [Story]
    let lastRecordId: Int?
    let hasNext: Bool
}
