//
//  UpdateHobbyStatusRequest.swift
//  Forday
//
//  Created by Subeen on 1/21/26.
//

import Foundation

extension DTO {
    struct UpdateHobbyStatusRequest: BaseRequest {
        let hobbyStatus: String
    }
}
