//
//  RecordsService.swift
//  Forday
//
//  Created by Subeen on 1/26/26.
//

import Foundation
import Moya

final class RecordsService {

    private let provider: MoyaProvider<RecordsTarget>

    init(provider: MoyaProvider<RecordsTarget> = NetworkProvider.createProvider()) {
        self.provider = provider
    }

    // MARK: - 활동 기록 상세 조회

    /// 활동 기록 상세 정보를 가져옵니다.
    ///
    /// - Parameter recordId: 조회할 활동 기록 ID
    /// - Returns: 활동 기록 상세 정보
    /// - Throws:
    ///   - `ACTIVITY_RECORD_NOT_FOUND` (404): 존재하지 않는 활동 기록
    ///   - `FRIEND_ONLY_ACCESS` (403): 친구 공개 글, 친구가 아닌 사용자 조회 시
    ///   - `PRIVATE_RECORD` (403): 나만보기 글, 작성자가 아닌 사용자 조회 시
    func fetchRecordDetail(recordId: Int) async throws -> DTO.ActivityRecordDetailResponse {
        return try await provider.request(.fetchRecordDetail(recordId: recordId))
    }
}
