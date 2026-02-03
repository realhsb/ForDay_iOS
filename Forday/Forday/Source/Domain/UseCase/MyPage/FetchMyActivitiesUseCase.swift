//
//  FetchMyActivitiesUseCase.swift
//  Forday
//
//  Created by Subeen on 1/23/26.
//

import Foundation

final class FetchMyActivitiesUseCase {

    private let repository: UsersRepositoryInterface

    init(repository: UsersRepositoryInterface = UsersRepository()) {
        self.repository = repository
    }

    func execute(hobbyIds: [Int], lastRecordId: Int? = nil, size: Int = 24) async throws -> FeedResult {
        return try await repository.fetchFeeds(hobbyIds: hobbyIds, lastRecordId: lastRecordId, feedSize: size)
    }
}
