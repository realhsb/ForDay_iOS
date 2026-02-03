//
//  ReactionType.swift
//  Forday
//
//  Created by Subeen on 1/30/26.
//

import Foundation

enum ReactionType: String, Codable, CaseIterable {
    case awesome = "AWESOME"    // 멋져요
    case great = "GREAT"        // 짱이야
    case amazing = "AMAZING"    // 대단해
    case fighting = "FIGHTING"  // 화이팅

    var displayName: String {
        switch self {
        case .awesome: return "멋져요"
        case .great: return "짱이야"
        case .amazing: return "대단해"
        case .fighting: return "화이팅"
        }
    }
}
