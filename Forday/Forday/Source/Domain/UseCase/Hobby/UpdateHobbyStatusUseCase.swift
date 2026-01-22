//
//  UpdateHobbyStatusUseCase.swift
//  Forday
//
//  Created by Subeen on 1/21/26.
//

import Foundation

final class UpdateHobbyStatusUseCase {

    private let repository: HobbyRepositoryInterface

    init(repository: HobbyRepositoryInterface = HobbyRepository()) {
        self.repository = repository
    }

    func execute(hobbyId: Int, hobbyStatus: HobbyStatus) async throws -> String {
        return try await repository.updateHobbyStatus(hobbyId: hobbyId, hobbyStatus: hobbyStatus)
    }
}
