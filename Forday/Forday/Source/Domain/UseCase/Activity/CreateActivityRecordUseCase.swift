//
//  CreateActivityRecordUseCase.swift
//  Forday
//
//  Created by Subeen on 1/21/26.
//

import Foundation

final class CreateActivityRecordUseCase {

    private let repository: ActivityRepositoryInterface

    init(repository: ActivityRepositoryInterface = ActivityRepository()) {
        self.repository = repository
    }

    func execute(
        activityId: Int,
        sticker: String,
        memo: String?,
        imageUrl: String?,
        visibility: Privacy
    ) async throws -> ActivityRecord {
        return try await repository.createActivityRecord(
            activityId: activityId,
            sticker: sticker,
            memo: memo,
            imageUrl: imageUrl,
            visibility: visibility
        )
    }
}
