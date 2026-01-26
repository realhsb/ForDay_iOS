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

    func fetchRecordDetail(recordId: Int) async throws -> DTO.ActivityRecordDetailResponse {
        return try await provider.request(.fetchRecordDetail(recordId: recordId))
    }
}
