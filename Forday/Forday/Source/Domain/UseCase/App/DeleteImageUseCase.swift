//
//  DeleteImageUseCase.swift
//  Forday
//
//  Created by Subeen on 1/21/26.
//

import Foundation

final class DeleteImageUseCase {

    private let repository: AppRepositoryInterface

    init(repository: AppRepositoryInterface = AppRepository()) {
        self.repository = repository
    }

    func execute(imageUrl: String) async throws -> String {
        return try await repository.deleteImage(imageUrl: imageUrl)
    }
}
