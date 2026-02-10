//
//  WithdrawResponse.swift
//  Forday
//
//  Created by Subeen on 2/7/26.
//

extension DTO {

    struct WithdrawResponse: BaseResponse {
        let status: Int
        let success: Bool
        let data: WithdrawData
    }

    struct WithdrawData: Codable {
        let message: String
        let deletedAt: String
    }
}
