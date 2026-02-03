//
//  StoriesService.swift
//  Forday
//
//  Created by Subeen on 2/1/26.
//

import Foundation
import Moya

final class StoriesService {

    private let provider: MoyaProvider<StoriesTarget>

    init(provider: MoyaProvider<StoriesTarget> = NetworkProvider.createProvider()) {
        self.provider = provider
    }

    /// Stories - 소식 탭 조회
    func fetchStoriesTabs() async throws -> DTO.StoriesTabsResponse {
        return try await provider.request(.fetchTabs)
    }

    /// Stories - 소식 목록 조회
    func fetchStories(
        hobbyId: Int?,
        lastRecordId: Int?,
        size: Int,
        keyword: String?
    ) async throws -> DTO.StoriesResponse {
        return try await provider.request(
            .fetchStories(
                hobbyId: hobbyId,
                lastRecordId: lastRecordId,
                size: size,
                keyword: keyword
            )
        )
    }
}
