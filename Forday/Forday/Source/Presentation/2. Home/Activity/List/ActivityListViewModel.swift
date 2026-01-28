//
//  ActivityListViewModel.swift
//  Forday
//
//  Created by Subeen on 1/16/26.
//


import Foundation
import Combine

class ActivityListViewModel {

    // Published Properties

    @Published var activities: [Activity] = []
    @Published var isLoading: Bool = false
    @Published var error: AppError?
    @Published var expandedActivityIds: Set<Int> = []

    private var cancellables = Set<AnyCancellable>()

    // UseCase
    private let fetchActivityListUseCase: FetchActivityListUseCase
    private let updateActivityUseCase: UpdateActivityUseCase
    private let deleteActivityUseCase: DeleteActivityUseCase
    private let fetchAIRecommendationsUseCase: FetchAIRecommendationsUseCase
    private let createActivitiesUseCase: CreateActivitiesUseCase

    // Initialization

    init(
        fetchActivityListUseCase: FetchActivityListUseCase = FetchActivityListUseCase(),
        updateActivityUseCase: UpdateActivityUseCase = UpdateActivityUseCase(),
        deleteActivityUseCase: DeleteActivityUseCase = DeleteActivityUseCase(),
        fetchAIRecommendationsUseCase: FetchAIRecommendationsUseCase = FetchAIRecommendationsUseCase(),
        createActivitiesUseCase: CreateActivitiesUseCase = CreateActivitiesUseCase()
    ) {
        self.fetchActivityListUseCase = fetchActivityListUseCase
        self.updateActivityUseCase = updateActivityUseCase
        self.deleteActivityUseCase = deleteActivityUseCase
        self.fetchAIRecommendationsUseCase = fetchAIRecommendationsUseCase
        self.createActivitiesUseCase = createActivitiesUseCase
    }
    
    // Methods
    
    func fetchActivities(hobbyId: Int) async {
        isLoading = true
        error = nil

        do {
            let activities = try await fetchActivityListUseCase.execute(hobbyId: hobbyId)

            await MainActor.run {
                self.activities = activities
                self.isLoading = false
                print("✅ 활동 목록 로드 완료: \(activities.count)개")
            }
        } catch let appError as AppError {
            await MainActor.run {
                self.error = appError
                self.isLoading = false
                print("❌ 활동 목록 로드 실패: \(appError)")
            }
        } catch {
            await MainActor.run {
                self.error = .unknown(error)
                self.isLoading = false
                print("❌ 활동 목록 로드 실패: \(error)")
            }
        }
    }
    
    func updateActivity(activityId: Int, content: String) async throws {
        let message = try await updateActivityUseCase.execute(activityId: activityId, content: content)
        print("✅ 활동 수정 완료: \(message)")
    }
    
    func deleteActivity(activityId: Int) async throws {
        let message = try await deleteActivityUseCase.execute(activityId: activityId)
        print("✅ 활동 삭제 완료: \(message)")

        // 목록에서 제거
        await MainActor.run {
            activities.removeAll { $0.activityId == activityId }
        }
    }

    func fetchAIRecommendations(hobbyId: Int) async throws -> AIRecommendationResult {
        return try await fetchAIRecommendationsUseCase.execute(hobbyId: hobbyId)
    }

    func createActivities(hobbyId: Int, activities: [ActivityInput]) async throws {
        let message = try await createActivitiesUseCase.execute(hobbyId: hobbyId, activities: activities)
        print("✅ 활동 생성 완료: \(message)")
    }

    // Expansion State Management

    func toggleExpansion(at index: Int) {
        guard index < activities.count else { return }

        let activity = activities[index]

        // 토글: 이미 확장되어 있으면 닫고, 아니면 열기
        if expandedActivityIds.contains(activity.activityId) {
            expandedActivityIds.remove(activity.activityId)
        } else {
            expandedActivityIds.insert(activity.activityId)
        }
    }

    func isExpanded(at index: Int) -> Bool {
        guard index < activities.count else { return false }
        return expandedActivityIds.contains(activities[index].activityId)
    }
}