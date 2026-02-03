//
//  DeleteRecordResponse.swift
//  Forday
//
//  Created by Subeen on 1/31/26.
//

import Foundation

extension DTO {
    struct DeleteRecordResponse: BaseResponse {
        let status: Int
        let success: Bool
        let data: DeleteRecordData
    }

    struct DeleteRecordData: Codable {
        let message: String
        let recordId: Int
    }
}

extension DTO.DeleteRecordResponse {
    func toDomain() -> DeleteRecordResult {
        return DeleteRecordResult(
            message: data.message,
            recordId: data.recordId
        )
    }
}
