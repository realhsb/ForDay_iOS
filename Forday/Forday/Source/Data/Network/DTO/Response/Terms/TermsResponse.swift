//
//  TermsResponse.swift
//  Forday
//
//  Created by Subeen on 2/7/26.
//

import Foundation

extension DTO {
    struct TermsResponse: BaseResponse {
        let status: Int
        let success: Bool
        let data: TermsData

        struct TermsData: Codable {
            let content: String
        }
    }
}
