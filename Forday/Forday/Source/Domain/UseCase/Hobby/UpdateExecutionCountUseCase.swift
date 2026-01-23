//
//  UpdateExecutionCountUseCase.swift
//  Forday
//
//  Created by Subeen on 1/21/26.
//

import Foundation

final class UpdateExecutionCountUseCase {

    private let repository: HobbyRepositoryInterface

    init(repository: HobbyRepositoryInterface = HobbyRepository()) {
        self.repository = repository
    }

    func execute(hobbyId: Int, executionCount: Int) async throws -> String {
        return try await repository.updateExecutionCount(hobbyId: hobbyId, executionCount: executionCount)
    }
}
