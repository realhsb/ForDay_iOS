//
//  FetchUserProfileUseCase.swift
//  Forday
//
//  Created by Subeen on 1/23/26.
//

import Foundation

final class FetchUserProfileUseCase {

    private let repository: UsersRepositoryInterface

    init(repository: UsersRepositoryInterface = UsersRepository()) {
        self.repository = repository
    }

    func execute() async throws -> UserInfo {
        return try await repository.fetchUserInfo()
    }
}
