//
//  CreateHobbyRequest.swift
//  Forday
//
//  Created by Subeen on 1/17/26.
//

import Foundation

extension DTO {
    struct CreateHobbyRequest: BaseRequest {
        let hobbyInfoId: Int?
        let hobbyName: String
        let hobbyTimeMinutes: Int
        let hobbyPurpose: String
        let executionCount: Int
        let isDurationSet: Bool

        enum CodingKeys: String, CodingKey {
            case hobbyInfoId, hobbyName, hobbyTimeMinutes, hobbyPurpose, executionCount, isDurationSet
        }

        func encode(to encoder: Encoder) throws {
            var container = encoder.container(keyedBy: CodingKeys.self)
            try container.encode(hobbyInfoId, forKey: .hobbyInfoId)  // nil이어도 null로 전송
            try container.encode(hobbyName, forKey: .hobbyName)
            try container.encode(hobbyTimeMinutes, forKey: .hobbyTimeMinutes)
            try container.encode(hobbyPurpose, forKey: .hobbyPurpose)
            try container.encode(executionCount, forKey: .executionCount)
            try container.encode(isDurationSet, forKey: .isDurationSet)
        }
    }
}
