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

    // MARK: - 활동 기록 반응 추가

    /// 활동 기록에 반응을 추가합니다.
    ///
    /// - Parameters:
    ///   - recordId: 반응을 추가할 활동 기록 ID
    ///   - reactionType: 반응 타입 (AWESOME, GREAT, AMAZING, FIGHTING)
    /// - Returns: 반응 추가 결과
    /// - Throws:
    ///   - `ACTIVITY_RECORD_NOT_FOUND` (404): 존재하지 않는 활동 기록
    ///   - `DUPLICATE_REACTION` (400): 이미 같은 반응을 남긴 경우
    ///   - `FRIEND_ONLY_ACCESS` (403): 친구 공개 글, 친구가 아닌 사용자 조회 시
    ///   - `PRIVATE_RECORD` (403): 나만보기 글, 작성자가 아닌 사용자 조회 시
    func addReaction(recordId: Int, reactionType: ReactionType) async throws -> DTO.AddReactionResponse {
        return try await provider.request(.addReaction(recordId: recordId, reactionType: reactionType))
    }

    // MARK: - 활동 기록 반응 취소

    /// 활동 기록의 반응을 취소합니다.
    ///
    /// - Parameters:
    ///   - recordId: 반응을 취소할 활동 기록 ID
    ///   - reactionType: 취소할 반응 타입 (AWESOME, GREAT, AMAZING, FIGHTING)
    /// - Returns: 반응 취소 결과
    /// - Throws:
    ///   - `ACTIVITY_RECORD_NOT_FOUND` (404): 존재하지 않는 활동 기록
    ///   - `REACTION_NOT_FOUND` (404): 해당 리액션이 존재하지 않거나 이미 취소된 경우
    func deleteReaction(recordId: Int, reactionType: ReactionType) async throws -> DTO.DeleteReactionResponse {
        return try await provider.request(.deleteReaction(recordId: recordId, reactionType: reactionType))
    }
}
