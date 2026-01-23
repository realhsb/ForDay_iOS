//
//  FetchStickerBoardUseCase.swift
//  Forday
//
//  Created by Subeen on 1/23/26.
//

import Foundation

final class FetchStickerBoardUseCase {

    private let repository: ActivityRepositoryInterface

    init(repository: ActivityRepositoryInterface = ActivityRepository()) {
        self.repository = repository
    }

    func execute(hobbyId: Int? = nil, page: Int? = nil, size: Int? = nil) async throws -> StickerBoardResult {
        return try await repository.fetchStickerBoard(hobbyId: hobbyId, page: page, size: size)
    }
}
