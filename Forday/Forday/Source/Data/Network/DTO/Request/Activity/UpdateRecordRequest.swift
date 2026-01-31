//
//  UpdateRecordRequest.swift
//  Forday
//
//  Created by Subeen on 1/31/26.
//

import Foundation

extension DTO {
    struct UpdateRecordRequest: BaseRequest {
        let activityId: Int
        let sticker: String
        let memo: String?
        let imageUrl: String?
        let visibility: String
    }
}
