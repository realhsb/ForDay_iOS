//
//  FetchUserProfileUseCase.swift
//  Forday
//
//  Created by Subeen on 1/23/26.
//

import Foundation

final class FetchUserProfileUseCase {

    private let repository: MyPageRepositoryInterface

    init(repository: MyPageRepositoryInterface = MyPageRepository()) {
        self.repository = repository
    }

    func execute() async throws -> UserProfile {
        return try await repository.fetchUserProfile()
    }
}
