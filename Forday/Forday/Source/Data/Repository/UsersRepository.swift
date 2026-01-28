//
//  UsersRepository.swift
//  Forday
//
//  Created by Subeen on 1/12/26.
//

import Foundation

final class UsersRepository: UsersRepositoryInterface {
    
    private let usersService: UsersService
    
    init(usersService: UsersService = UsersService()) {
        self.usersService = usersService
    }
    
    // MARK: - Nickname Availability Check
    
    func checkNicknameAvailability(nickname: String) async throws -> NicknameCheckResult {
        let response = try await usersService.checkNicknameAvailability(nickname: nickname)
        return response.toDomain()
    }
    
    // MARK: - Set Nickname

    // UsersRepository.swift
    func setNickname(nickname: String) async throws -> SetNicknameResult {
        let request = DTO.SetNicknameRequest(nickname: nickname)
        let response = try await usersService.setNickname(request: request)
        return response.toDomain()
    }

    // MARK: - Fetch Hobby Cards

    func fetchHobbyCards(lastHobbyCardId: Int?, size: Int = 20) async throws -> HobbyCardsResult {
        let response = try await usersService.fetchHobbyCards(lastHobbyCardId: lastHobbyCardId, size: size)
        return response.toDomain()
    }

    // MARK: - Update Profile Image

    func updateProfileImage(profileImageUrl: String) async throws -> UpdateProfileImageResult {
        let response = try await usersService.updateProfileImage(profileImageUrl: profileImageUrl)
        return response.toDomain()
    }

    // MARK: - Fetch Feeds

    func fetchFeeds(hobbyId: Int?, lastRecordId: Int?, feedSize: Int = 24) async throws -> FeedResult {
        let response = try await usersService.fetchFeeds(hobbyId: hobbyId, lastRecordId: lastRecordId, feedSize: feedSize)
        return response.toDomain(requestedSize: feedSize)
    }
}
