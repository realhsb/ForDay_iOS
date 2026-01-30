//
//  DeleteReactionResponse.swift
//  Forday
//
//  Created by Subeen on 1/30/26.
//

import Foundation

extension DTO {
    struct DeleteReactionResponse: BaseResponse {
        let status: Int
        let success: Bool
        let data: DeleteReactionData
    }

    struct DeleteReactionData: Codable {
        let message: String
        let reactionType: String
        let recordId: Int
    }
}

// MARK: - Domain Mapping

extension DTO.DeleteReactionResponse {
    func toDomain() -> DeleteReactionResult {
        return DeleteReactionResult(
            message: data.message,
            reactionType: ReactionType(rawValue: data.reactionType) ?? .awesome,
            recordId: data.recordId
        )
    }
}
