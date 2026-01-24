//
//  FetchHobbyCardsUseCase.swift
//  Forday
//
//  Created by Subeen on 1/23/26.
//

import Foundation

final class FetchHobbyCardsUseCase {

    private let repository: MyPageRepositoryInterface

    init(repository: MyPageRepositoryInterface = MyPageRepository()) {
        self.repository = repository
    }

    func execute(page: Int) async throws -> [HobbyCardData] {
        return try await repository.fetchHobbyCards(page: page)
    }
}
