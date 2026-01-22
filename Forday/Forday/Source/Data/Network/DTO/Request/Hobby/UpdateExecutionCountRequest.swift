//
//  UpdateExecutionCountRequest.swift
//  Forday
//
//  Created by Subeen on 1/21/26.
//

import Foundation

extension DTO {
    struct UpdateExecutionCountRequest: BaseRequest {
        let executionCount: Int
    }
}
