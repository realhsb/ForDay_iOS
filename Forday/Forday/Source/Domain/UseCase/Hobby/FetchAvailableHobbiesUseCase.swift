//
//  FetchAvailableHobbiesUseCase.swift
//  Forday
//
//  Created by Subeen on 2/6/26.
//

import Foundation

/// 취미 추가 시 선택 가능한 취미 목록 조회 (이미 생성한 취미 제외)
final class FetchAvailableHobbiesUseCase {

    private let activityService: ActivityService

    init(activityService: ActivityService = ActivityService()) {
        self.activityService = activityService
    }

    func execute() async throws -> [HobbyCard] {
        let response = try await activityService.fetchHobbyInfoRecheck()
        return response.toDomain()
    }
}
