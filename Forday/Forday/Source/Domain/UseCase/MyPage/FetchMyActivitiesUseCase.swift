//
//  FetchMyActivitiesUseCase.swift
//  Forday
//
//  Created by Subeen on 1/23/26.
//

import Foundation

final class FetchMyActivitiesUseCase {

    private let repository: MyPageRepositoryInterface

    init(repository: MyPageRepositoryInterface = MyPageRepository()) {
        self.repository = repository
    }

    func execute(hobbyId: Int?, page: Int, size: Int = 20) async throws -> MyActivitiesResult {
        return try await repository.fetchMyActivities(hobbyId: hobbyId, page: page, size: size)
    }
}
