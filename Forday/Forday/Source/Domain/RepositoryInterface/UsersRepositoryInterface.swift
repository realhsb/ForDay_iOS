//
//  UsersRepositoryInterface.swift
//  Forday
//
//  Created by Subeen on 1/12/26.
//


import Foundation

protocol UsersRepositoryInterface {
    func checkNicknameAvailability(nickname: String) async throws -> NicknameCheckResult
    func setNickname(nickname: String) async throws -> SetNicknameResult
    func fetchHobbyCards(lastHobbyCardId: Int?, size: Int) async throws -> HobbyCardsResult
    func updateProfileImage(profileImageUrl: String) async throws -> UpdateProfileImageResult
    func fetchFeeds(hobbyId: Int?, lastRecordId: Int?, feedSize: Int) async throws -> FeedResult
}
