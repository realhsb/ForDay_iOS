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
    
    func setNickname(nickname: String) async throws {
        // TODO: 나중에 구현
        fatalError("setNickname not implemented yet")
    }
}
