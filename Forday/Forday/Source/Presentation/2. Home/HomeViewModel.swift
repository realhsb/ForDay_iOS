//
//  HomeViewModel.swift
//  Forday
//
//  Created by Subeen on 1/14/26.
//


import Foundation
import Combine

class HomeViewModel {

    // Published Properties

    @Published var homeInfo: HomeInfo?
    @Published var activities: [Activity] = []
    @Published var aiRecommendationResult: AIRecommendationResult?
    @Published var currentHobbyId: Int?
    @Published var isLoading: Bool = false
    @Published var errorMessage: String?

    private var cancellables = Set<AnyCancellable>()

    // UseCase
    private let fetchHomeInfoUseCase: FetchHomeInfoUseCase
    private let fetchAIRecommendationsUseCase: FetchAIRecommendationsUseCase
    private let fetchActivityListUseCase: FetchActivityListUseCase

    // Initialization

    init(
        fetchHomeInfoUseCase: FetchHomeInfoUseCase = FetchHomeInfoUseCase(),
        fetchAIRecommendationsUseCase: FetchAIRecommendationsUseCase = FetchAIRecommendationsUseCase(),
        fetchActivityListUseCase: FetchActivityListUseCase = FetchActivityListUseCase()
    ) {
        self.fetchHomeInfoUseCase = fetchHomeInfoUseCase
        self.fetchAIRecommendationsUseCase = fetchAIRecommendationsUseCase
        self.fetchActivityListUseCase = fetchActivityListUseCase
    }
    
    // Methods

    func fetchHomeInfo() async {
        isLoading = true
        errorMessage = nil

        do {
            let info = try await fetchHomeInfoUseCase.execute(hobbyId: nil)
            await MainActor.run {
                self.homeInfo = info
                // currentHobby가 true인 취미의 hobbyId 저장
                if let currentHobby = info.inProgressHobbies.first(where: { $0.currentHobby }) {
                    self.currentHobbyId = currentHobby.hobbyId
                    print("✅ 홈 정보 로드 성공 - hobbyId: \(currentHobby.hobbyId)")
                }
                self.isLoading = false
            }
        } catch {
            await MainActor.run {
                self.errorMessage = error.localizedDescription
                self.isLoading = false
                print("❌ 홈 정보 로드 실패: \(error)")
            }
        }
    }

    func fetchAIRecommendations() async throws {
        guard let hobbyId = currentHobbyId else {
            throw NSError(domain: "HomeViewModel", code: -1, userInfo: [NSLocalizedDescriptionKey: "취미 정보 없음"])
        }

        print("🔍 AI 추천 요청 시작 - hobbyId: \(hobbyId)")

        let result = try await fetchAIRecommendationsUseCase.execute(hobbyId: hobbyId)

        await MainActor.run {
            self.aiRecommendationResult = result
            print("✅ AI 추천 완료: \(result.activities.count)개")
            print("호출 횟수: \(result.aiCallCount)/\(result.aiCallLimit)")
        }
    }

    func fetchActivityList() async throws -> [Activity] {
        guard let hobbyId = currentHobbyId else {
            throw NSError(domain: "HomeViewModel", code: -1, userInfo: [NSLocalizedDescriptionKey: "취미 정보 없음"])
        }

        let activities = try await fetchActivityListUseCase.execute(hobbyId: hobbyId)

        await MainActor.run {
            self.activities = activities
            print("✅ 활동 목록 로드 완료: \(activities.count)개")
        }

        return activities
    }
}

// MARK: - Models

//struct Activity {
//    let id: Int
//    let name: String
//    let isCompleted: Bool
//}
