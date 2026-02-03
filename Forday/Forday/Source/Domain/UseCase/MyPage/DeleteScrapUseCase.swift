//
//  DeleteScrapUseCase.swift
//  Forday
//
//  Created by Subeen on 2/1/26.
//

import Foundation

final class DeleteScrapUseCase {

    private let repository: MyPageRepositoryInterface

    init(repository: MyPageRepositoryInterface = MyPageRepository()) {
        self.repository = repository
    }

    func execute(recordId: Int) async throws -> ScrapResult {
        return try await repository.deleteScrap(recordId: recordId)
    }
}
