//
//  Privacy.swift
//  Forday
//
//  Created by Subeen on 1/21/26.
//

import Foundation

enum Privacy: String {
    case `public` = "PUBLIC"
    case friend = "FRIEND"
    case `private` = "PRIVATE"

    var title: String {
        switch self {
        case .public: return "전체공개"
        case .friend: return "친구공개"
        case .private: return "나만보기"
        }
    }
}
