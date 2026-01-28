//
//  HobbyRepositoryInterface.swift
//  Forday
//
//  Created by Subeen on 1/17/26.
//

import Foundation

protocol HobbyRepositoryInterface {
    func createHobby(
        hobbyCardId: Int,
        hobbyName: String,
        hobbyTimeMinutes: Int,
        hobbyPurpose: String,
        executionCount: Int,
        isDurationSet: Bool
    ) async throws -> Int

    func fetchHomeInfo(hobbyId: Int?) async throws -> HomeInfo

    // Hobby Management
    func fetchHobbySettings(hobbyStatus: HobbyStatus?) async throws -> HobbySettings
    func updateHobbyTime(hobbyId: Int, minutes: Int) async throws -> String
    func updateExecutionCount(hobbyId: Int, executionCount: Int) async throws -> String
    func updateGoalDays(hobbyId: Int, isDurationSet: Bool) async throws -> String
    func updateHobbyStatus(hobbyId: Int, hobbyStatus: HobbyStatus) async throws -> String
    func updateCoverImage(hobbyId: Int?, coverImageUrl: String?, recordId: Int?) async throws -> UpdateHobbyCoverResult
}
