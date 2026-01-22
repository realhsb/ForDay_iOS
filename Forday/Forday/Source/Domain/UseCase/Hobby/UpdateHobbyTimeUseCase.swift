//
//  UpdateHobbyTimeUseCase.swift
//  Forday
//
//  Created by Subeen on 1/21/26.
//

import Foundation

final class UpdateHobbyTimeUseCase {

    private let repository: HobbyRepositoryInterface

    init(repository: HobbyRepositoryInterface = HobbyRepository()) {
        self.repository = repository
    }

    func execute(hobbyId: Int, minutes: Int) async throws -> String {
        return try await repository.updateHobbyTime(hobbyId: hobbyId, minutes: minutes)
    }
}
