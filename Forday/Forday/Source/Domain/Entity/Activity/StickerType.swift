//
//  StickerType.swift
//  Forday
//
//  Created by Subeen on 1/28/26.
//

import UIKit

/// Represents the type of sticker that can be used in activity records
enum StickerType: String, Codable, CaseIterable {
    case smile = "smile.jpg"
    case sad = "sad.jpg"
    case laugh = "laugh.jpg"
    case angry = "angry.jpg"

    /// Returns the corresponding UIImage asset for the sticker
    var image: UIImage {
        switch self {
        case .smile:
            return .My.smileJpg
        case .sad:
            return .My.sadJpg
        case .laugh:
            return .My.laughJpg
        case .angry:
            return .My.angryJpg
        }
    }

    /// Initialize from a filename string
    /// - Parameter fileName: The sticker filename (e.g., "smile.jpg")
    /// - Returns: The corresponding StickerType, or nil if not recognized
    init?(fileName: String) {
        self.init(rawValue: fileName)
    }

    /// Initialize from UIImage by comparing with known sticker images
    /// - Parameter image: The UIImage to match
    /// - Returns: The corresponding StickerType, or nil if not matched
    init?(image: UIImage) {
        if image == .My.smileJpg {
            self = .smile
        } else if image == .My.sadJpg {
            self = .sad
        } else if image == .My.laughJpg {
            self = .laugh
        } else if image == .My.angryJpg {
            self = .angry
        } else {
            return nil
        }
    }
}
