//
//  GuestLoginRequest.swift
//  Forday
//
//  Created by Subeen on 1/11/26.
//

import Foundation

extension DTO {
    struct GuestLoginRequest: BaseRequest {
        let guestUserId: String?
    }
}
