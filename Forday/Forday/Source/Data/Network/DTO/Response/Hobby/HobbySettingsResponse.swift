//
//  HobbySettingsResponse.swift
//  Forday
//
//  Created by Subeen on 1/21/26.
//

import Foundation

extension DTO {
    struct HobbySettingsResponse: BaseResponse {
        let status: Int
        let success: Bool
        let data: HobbySettingsData
    }

    struct HobbySettingsData: Codable {
        let currentHobbyStatus: String
        let inProgressHobbyCount: Int
        let archivedHobbyCount: Int
        let hobbies: [HobbyInfoDTO]
    }

    struct HobbyInfoDTO: Codable {
        let hobbyId: Int
        let hobbyName: String
        let hobbyTimeMinutes: Int
        let executionCount: Int
        let goalDays: Int?
    }
}

extension DTO.HobbySettingsResponse {
    func toDomain() -> HobbySettings {
        let status = HobbyStatus(rawValue: data.currentHobbyStatus) ?? .inProgress

        let hobbies = data.hobbies.map { dto in
            HobbySetting(
                hobbyId: dto.hobbyId,
                hobbyName: dto.hobbyName,
                hobbyTimeMinutes: dto.hobbyTimeMinutes,
                executionCount: dto.executionCount,
                goalDays: dto.goalDays
            )
        }

        return HobbySettings(
            currentHobbyStatus: status,
            inProgressHobbyCount: data.inProgressHobbyCount,
            archivedHobbyCount: data.archivedHobbyCount,
            hobbies: hobbies
        )
    }
}
