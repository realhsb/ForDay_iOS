//
//  ReactionStatus.swift
//  Forday
//
//  Created by Subeen on 1/26/26.
//

import Foundation

struct ReactionStatus {
    let awesome: Bool
    let great: Bool
    let amazing: Bool
    let fighting: Bool
}

// MARK: - Preview

#if DEBUG
extension ReactionStatus {
    static var preview: ReactionStatus {
        ReactionStatus(awesome: true, great: false, amazing: false, fighting: false)
    }

    static var previewAll: ReactionStatus {
        ReactionStatus(awesome: true, great: true, amazing: true, fighting: true)
    }

    static var previewNone: ReactionStatus {
        ReactionStatus(awesome: false, great: false, amazing: false, fighting: false)
    }
}
#endif
