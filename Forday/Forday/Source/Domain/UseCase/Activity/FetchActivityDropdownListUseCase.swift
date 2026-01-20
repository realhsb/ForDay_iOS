//
//  FetchActivityDropdownListUseCase.swift
//  Forday
//
//  Created by Subeen on 1/20/26.
//

import Foundation

final class FetchActivityDropdownListUseCase {

    private let repository: ActivityRepositoryInterface

    init(repository: ActivityRepositoryInterface = ActivityRepository()) {
        self.repository = repository
    }

    func execute(hobbyId: Int, size: Int? = nil) async throws -> [Activity] {
        return try await repository.fetchActivityDropdownList(hobbyId: hobbyId, size: size)
    }
}
