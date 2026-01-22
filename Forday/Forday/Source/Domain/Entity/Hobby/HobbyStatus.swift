//
//  HobbyStatus.swift
//  Forday
//
//  Created by Subeen on 1/21/26.
//

import Foundation

enum HobbyStatus: String, Codable {
    case inProgress = "IN_PROGRESS"
    case archived = "ARCHIVED"

    var title: String {
        switch self {
        case .inProgress: return "진행중"
        case .archived: return "보관함"
        }
    }
}
