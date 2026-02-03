//
//  DeleteActivityRecordUseCase.swift
//  Forday
//
//  Created by Subeen on 1/31/26.
//

import Foundation

final class DeleteActivityRecordUseCase {

    private let recordsService: RecordsService

    init(recordsService: RecordsService = RecordsService()) {
        self.recordsService = recordsService
    }

    /// 활동 기록을 삭제합니다.
    ///
    /// - Parameter recordId: 삭제할 활동 기록 ID
    /// - Returns: 삭제 결과
    /// - Throws: API 에러
    func execute(recordId: Int) async throws -> DeleteRecordResult {
        let response = try await recordsService.deleteRecord(recordId: recordId)
        return response.toDomain()
    }
}
