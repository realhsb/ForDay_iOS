//
//  UpdateProfileUseCase.swift
//  Forday
//
//  Created by Subeen on 1/23/26.
//

import Foundation

final class UpdateProfileUseCase {

    private let repository: MyPageRepositoryInterface

    init(repository: MyPageRepositoryInterface = MyPageRepository()) {
        self.repository = repository
    }

    func execute(nickname: String?, profileImageUrl: String?) async throws -> UserProfile {
        return try await repository.updateProfile(nickname: nickname, profileImageUrl: profileImageUrl)
    }
}
