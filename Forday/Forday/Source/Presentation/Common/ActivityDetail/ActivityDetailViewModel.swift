//
//  ActivityDetailViewModel.swift
//  Forday
//
//  Created by Subeen on 1/23/26.
//

import Foundation
import Combine

final class ActivityDetailViewModel {

    // MARK: - Published Properties

    @Published var activityDetail: ActivityDetail?
    @Published var isLoading: Bool = false
    @Published var error: AppError?

    // MARK: - Private Properties

    private let activityRecordId: Int
    private let fetchActivityDetailUseCase: FetchActivityDetailUseCase
    private let addReactionUseCase: AddReactionUseCase
    private let deleteReactionUseCase: DeleteReactionUseCase

    // MARK: - Public Properties

    var hobbyId: Int {
        return activityDetail?.hobbyId ?? 0
    }

    // MARK: - Initialization

    init(
        activityRecordId: Int,
        fetchActivityDetailUseCase: FetchActivityDetailUseCase = FetchActivityDetailUseCase(),
        addReactionUseCase: AddReactionUseCase = AddReactionUseCase(),
        deleteReactionUseCase: DeleteReactionUseCase = DeleteReactionUseCase()
    ) {
        self.activityRecordId = activityRecordId
        self.fetchActivityDetailUseCase = fetchActivityDetailUseCase
        self.addReactionUseCase = addReactionUseCase
        self.deleteReactionUseCase = deleteReactionUseCase
    }

    // MARK: - Public Methods

    func fetchDetail() async {
        await MainActor.run {
            isLoading = true
        }

        do {
            let detail = try await fetchActivityDetailUseCase.execute(activityRecordId: activityRecordId)

            await MainActor.run {
                self.activityDetail = detail
                self.isLoading = false
            }

        } catch let appError as AppError {
            await MainActor.run {
                self.error = appError
                self.isLoading = false
            }
        } catch {
            await MainActor.run {
                self.error = .unknown(error)
                self.isLoading = false
            }
        }
    }

    // MARK: - Reaction Methods

    /// 반응을 추가하거나 삭제합니다.
    /// 이미 눌러진 반응이면 삭제, 아니면 추가합니다.
    func toggleReaction(_ reactionType: ReactionType) async {
        guard let detail = activityDetail else { return }

        // 현재 반응 상태 확인
        let isCurrentlyPressed = isReactionPressed(reactionType, in: detail.userReaction)

        do {
            if isCurrentlyPressed {
                // 반응 삭제
                _ = try await deleteReactionUseCase.execute(
                    recordId: activityRecordId,
                    reactionType: reactionType
                )
            } else {
                // 반응 추가
                _ = try await addReactionUseCase.execute(
                    recordId: activityRecordId,
                    reactionType: reactionType
                )
            }

            // 성공 시 상세 정보 다시 불러오기
            await fetchDetail()

        } catch let appError as AppError {
            await MainActor.run {
                self.error = appError
            }
        } catch {
            await MainActor.run {
                self.error = .unknown(error)
            }
        }
    }

    private func isReactionPressed(_ reactionType: ReactionType, in reaction: ReactionStatus) -> Bool {
        switch reactionType {
        case .awesome: return reaction.awesome
        case .great: return reaction.great
        case .amazing: return reaction.amazing
        case .fighting: return reaction.fighting
        }
    }
}
