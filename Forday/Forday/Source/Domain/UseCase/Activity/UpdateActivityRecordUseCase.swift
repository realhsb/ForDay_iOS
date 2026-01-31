//
//  UpdateActivityRecordUseCase.swift
//  Forday
//
//  Created by Subeen on 1/31/26.
//

import Foundation

final class UpdateActivityRecordUseCase {

    private let recordsService: RecordsService

    init(recordsService: RecordsService = RecordsService()) {
        self.recordsService = recordsService
    }

    /// 활동 기록을 수정합니다.
    ///
    /// - Parameters:
    ///   - recordId: 수정할 활동 기록 ID
    ///   - activityId: 변경할 활동 ID
    ///   - sticker: 스티커 파일명 (예: "smile.jpg")
    ///   - memo: 메모 (옵션)
    ///   - imageUrl: S3 이미지 URL (옵션)
    ///   - visibility: 공개 범위 (PUBLIC, FRIEND, PRIVATE)
    /// - Returns: 수정된 활동 기록 정보
    /// - Throws: API 에러
    func execute(
        recordId: Int,
        activityId: Int,
        sticker: String,
        memo: String?,
        imageUrl: String?,
        visibility: Privacy
    ) async throws -> UpdateRecordResult {
        let request = DTO.UpdateRecordRequest(
            activityId: activityId,
            sticker: sticker,
            memo: memo,
            imageUrl: imageUrl,
            visibility: visibility.rawValue
        )

        let response = try await recordsService.updateRecord(recordId: recordId, request: request)
        return response.toDomain()
    }
}
