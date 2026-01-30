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

    /// Returns the gradient associated with this sticker type
    var gradient: AppGradient {
        switch self {
        case .smile:
            return DesignGradient.stickerSmile
        case .sad:
            return DesignGradient.stickerSad
        case .angry:
            return DesignGradient.stickerAngry
        case .laugh:
            return DesignGradient.stickerLaugh
        }
    }

    /// Initialize from a filename string
    /// - Parameter fileName: The sticker filename (e.g., "smile.jpg")
    /// - Returns: The corresponding StickerType, or nil if not recognized
    init?(fileName: String) {
        self.init(rawValue: fileName)
    }
}
