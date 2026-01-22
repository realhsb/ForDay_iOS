//
//  UpdateGoalDaysUseCase.swift
//  Forday
//
//  Created by Subeen on 1/21/26.
//

import Foundation

final class UpdateGoalDaysUseCase {

    private let repository: HobbyRepositoryInterface

    init(repository: HobbyRepositoryInterface = HobbyRepository()) {
        self.repository = repository
    }

    func execute(hobbyId: Int, isDurationSet: Bool) async throws -> String {
        return try await repository.updateGoalDays(hobbyId: hobbyId, isDurationSet: isDurationSet)
    }
}
