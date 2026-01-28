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

    func execute(hobbyId: Int?, lastRecordId: Int? = nil, size: Int = 24) async throws -> FeedResult {
        return try await repository.fetchMyActivities(hobbyId: hobbyId, lastRecordId: lastRecordId, size: size)
    }
}
