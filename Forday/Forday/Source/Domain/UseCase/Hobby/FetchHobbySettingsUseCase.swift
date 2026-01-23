//
//  FetchHobbySettingsUseCase.swift
//  Forday
//
//  Created by Subeen on 1/21/26.
//

import Foundation

final class FetchHobbySettingsUseCase {

    private let repository: HobbyRepositoryInterface

    init(repository: HobbyRepositoryInterface = HobbyRepository()) {
        self.repository = repository
    }

    func execute(hobbyStatus: HobbyStatus? = nil) async throws -> HobbySettings {
        return try await repository.fetchHobbySettings(hobbyStatus: hobbyStatus)
    }
}
