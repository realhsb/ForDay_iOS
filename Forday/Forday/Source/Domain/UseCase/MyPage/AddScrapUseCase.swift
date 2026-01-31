//
//  AddScrapUseCase.swift
//  Forday
//
//  Created by Subeen on 2/1/26.
//

import Foundation

final class AddScrapUseCase {

    private let repository: MyPageRepositoryInterface

    init(repository: MyPageRepositoryInterface = MyPageRepository()) {
        self.repository = repository
    }

    func execute(recordId: Int) async throws -> ScrapResult {
        return try await repository.addScrap(recordId: recordId)
    }
}
