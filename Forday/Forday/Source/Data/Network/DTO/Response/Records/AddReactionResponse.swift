//
//  AddReactionResponse.swift
//  Forday
//
//  Created by Subeen on 1/30/26.
//

import Foundation

extension DTO {
    struct AddReactionResponse: BaseResponse {
        let status: Int
        let success: Bool
        let data: AddReactionData
    }

    struct AddReactionData: Codable {
        let message: String
        let reactionType: String
        let recordId: Int
    }
}

// MARK: - Domain Mapping

extension DTO.AddReactionResponse {
    func toDomain() -> AddReactionResult {
        return AddReactionResult(
            message: data.message,
            reactionType: ReactionType(rawValue: data.reactionType) ?? .awesome,
            recordId: data.recordId
        )
    }
}
