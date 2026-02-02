//
//  FetchStoriesTabsUseCase.swift
//  Forday
//
//  Created by Subeen on 2/1/26.
//

import Foundation

final class FetchStoriesTabsUseCase {

    private let repository: StoriesRepositoryInterface

    init(repository: StoriesRepositoryInterface = StoriesRepository()) {
        self.repository = repository
    }

    func execute() async throws -> [StoriesTab] {
        return try await repository.fetchStoriesTabs()
    }
}
