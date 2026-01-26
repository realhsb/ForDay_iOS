//
//  FetchHobbyCardsUseCase.swift
//  Forday
//
//  Created by Subeen on 1/23/26.
//

import Foundation

final class FetchHobbyCardsUseCase {

    private let repository: UsersRepositoryInterface

    init(repository: UsersRepositoryInterface = UsersRepository()) {
        self.repository = repository
    }

    func execute(lastHobbyCardId: Int?, size: Int = 20) async throws -> HobbyCardsResult {
        return try await repository.fetchHobbyCards(lastHobbyCardId: lastHobbyCardId, size: size)
    }
}
