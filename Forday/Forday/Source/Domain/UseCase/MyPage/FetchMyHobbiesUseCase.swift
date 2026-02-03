//
//  FetchMyHobbiesUseCase.swift
//  Forday
//
//  Created by Subeen on 1/23/26.
//

import Foundation

final class FetchMyHobbiesUseCase {

    private let repository: MyPageRepositoryInterface

    init(repository: MyPageRepositoryInterface = MyPageRepository()) {
        self.repository = repository
    }

    func execute() async throws -> MyHobbiesResult {
        return try await repository.fetchMyHobbies()
    }
}
