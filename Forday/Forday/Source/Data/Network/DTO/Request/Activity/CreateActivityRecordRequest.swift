//
//  CreateActivityRecordRequest.swift
//  Forday
//
//  Created by Subeen on 1/21/26.
//

import Foundation

extension DTO {
    struct CreateActivityRecordRequest: BaseRequest {
        let sticker: String
        let memo: String?
        let imageUrl: String?
        let visibility: String
    }
}
