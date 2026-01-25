//
//  MyPageViewModel.swift
//  Forday
//
//  Created by Subeen on 1/23/26.
//

import Foundation
import Combine

enum MyPageTab {
    case activities
    case hobbyCards
}

final class MyPageViewModel {

    // MARK: - Published Properties

    @Published var userProfile: UserProfile?
    @Published var currentTab: MyPageTab = .activities
    @Published var myHobbies: [MyPageHobby] = []
    @Published var activities: [MyPageActivity] = []
    @Published var hobbyCards: [HobbyCardData] = []
    @Published var selectedHobbyId: Int? // nil = all hobbies
    @Published var isLoading: Bool = false
    @Published var isLoadingMore: Bool = false
    @Published var errorMessage: String?

    // MARK: - Private Properties

    private var lastRecordId: Int? = nil
    private var hasMoreActivities: Bool = true

    // Use Cases
    private let fetchUserProfileUseCase: FetchUserProfileUseCase
    private let fetchMyActivitiesUseCase: FetchMyActivitiesUseCase
    private let fetchMyHobbiesUseCase: FetchMyHobbiesUseCase
    private let fetchHobbyCardsUseCase: FetchHobbyCardsUseCase

    // MARK: - Initialization

    init(
        fetchUserProfileUseCase: FetchUserProfileUseCase = FetchUserProfileUseCase(),
        fetchMyActivitiesUseCase: FetchMyActivitiesUseCase = FetchMyActivitiesUseCase(),
        fetchMyHobbiesUseCase: FetchMyHobbiesUseCase = FetchMyHobbiesUseCase(),
        fetchHobbyCardsUseCase: FetchHobbyCardsUseCase = FetchHobbyCardsUseCase()
    ) {
        self.fetchUserProfileUseCase = fetchUserProfileUseCase
        self.fetchMyActivitiesUseCase = fetchMyActivitiesUseCase
        self.fetchMyHobbiesUseCase = fetchMyHobbiesUseCase
        self.fetchHobbyCardsUseCase = fetchHobbyCardsUseCase
    }

    // MARK: - Public Methods

    func fetchInitialData() async {
        await MainActor.run {
            isLoading = true
        }

        do {
            // Fetch all data in parallel
            async let profileTask = fetchUserProfileUseCase.execute()
            async let hobbiesTask = fetchMyHobbiesUseCase.execute()
            async let activitiesTask = fetchMyActivitiesUseCase.execute(hobbyId: nil, lastRecordId: nil)
            async let cardsTask = fetchHobbyCardsUseCase.execute(page: 0)

            let (profile, hobbies, activitiesResult, cards) = try await (
                profileTask,
                hobbiesTask,
                activitiesTask,
                cardsTask
            )

            await MainActor.run {
                self.userProfile = profile
                self.myHobbies = hobbies
                self.activities = activitiesResult.activities
                self.hobbyCards = cards
                self.hasMoreActivities = activitiesResult.hasNext
                self.lastRecordId = activitiesResult.lastRecordId
                self.isLoading = false
            }

        } catch {
            await MainActor.run {
                self.errorMessage = error.localizedDescription
                self.isLoading = false
            }
        }
    }

    func switchTab(to tab: MyPageTab) {
        currentTab = tab
    }

    func filterByHobby(hobbyId: Int?) async {
        selectedHobbyId = hobbyId
        lastRecordId = nil
        hasMoreActivities = true

        await refreshActivities()
    }

    func refreshActivities() async {
        await MainActor.run {
            isLoading = true
        }

        do {
            let result = try await fetchMyActivitiesUseCase.execute(
                hobbyId: selectedHobbyId,
                lastRecordId: nil
            )

            await MainActor.run {
                self.activities = result.activities
                self.hasMoreActivities = result.hasNext
                self.lastRecordId = result.lastRecordId
                self.isLoading = false
            }

        } catch {
            await MainActor.run {
                self.errorMessage = error.localizedDescription
                self.isLoading = false
            }
        }
    }

    func loadMoreActivities() async {
        guard !isLoadingMore && hasMoreActivities else { return }

        await MainActor.run {
            isLoadingMore = true
        }

        do {
            let result = try await fetchMyActivitiesUseCase.execute(
                hobbyId: selectedHobbyId,
                lastRecordId: lastRecordId
            )

            await MainActor.run {
                self.activities.append(contentsOf: result.activities)
                self.hasMoreActivities = result.hasNext
                self.lastRecordId = result.lastRecordId
                self.isLoadingMore = false
            }

        } catch {
            await MainActor.run {
                self.errorMessage = error.localizedDescription
                self.isLoadingMore = false
            }
        }
    }
}
