//
//  UpdateHobbyCoverRequest.swift
//  Forday
//
//  Created by Subeen on 1/27/26.
//

extension DTO {
    struct UpdateHobbyCoverRequest: Codable {
        let hobbyId: Int?
        let coverImageUrl: String?
        let recordId: Int?
    }
}
