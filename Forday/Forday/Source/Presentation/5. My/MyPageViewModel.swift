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

    @Published var userProfile: UserInfo?
    @Published var currentTab: MyPageTab = .activities
    @Published var myHobbies: [MyPageHobby] = []
    @Published var inProgressHobbyCount: Int = 0  // Segment "진행 중(n)" 표시용
    @Published var hobbyCardCount: Int = 0        // Segment "취미 카드(n)" 표시용
    @Published var activities: [MyPageActivity] = []
    @Published var hobbyCards: [CompletedHobbyCard] = []
    @Published var selectedHobbyId: Int? // nil = all hobbies
    @Published var isLoading: Bool = false
    @Published var isLoadingMore: Bool = false
    @Published var error: AppError?

    // MARK: - Private Properties

    private var lastRecordId: Int? = nil
    private var hasMoreActivities: Bool = true
    private var lastHobbyCardId: Int? = nil
    private var hasMoreHobbyCards: Bool = true

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

        // Fetch all data in parallel, each can fail independently
        async let profile = try? await fetchUserProfileUseCase.execute()
        async let hobbiesResult = try? await fetchMyHobbiesUseCase.execute()
        async let activitiesResult = try? await fetchMyActivitiesUseCase.execute(hobbyId: nil, lastRecordId: nil)
        async let cardsResult = try? await fetchHobbyCardsUseCase.execute(lastHobbyCardId: nil, size: 20)

        let (profileOpt, hobbiesOpt, activitiesOpt, cardsOpt) = await (
            profile,
            hobbiesResult,
            activitiesResult,
            cardsResult
        )

        await MainActor.run {
            // Update only successful results
            if let profile = profileOpt {
                self.userProfile = profile
            }

            if let hobbies = hobbiesOpt {
                self.myHobbies = hobbies.hobbies
                self.inProgressHobbyCount = hobbies.inProgressHobbyCount
                self.hobbyCardCount = hobbies.hobbyCardCount
            }

            if let activities = activitiesOpt {
                self.activities = activities.activities
                self.hasMoreActivities = activities.hasNext
                self.lastRecordId = activities.lastRecordId
            }

            if let cards = cardsOpt {
                self.hobbyCards = cards.cards
                self.hasMoreHobbyCards = cards.hasNext
                self.lastHobbyCardId = cards.lastCardId
            }

            self.isLoading = false
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

        } catch let appError as AppError {
            await MainActor.run {
                self.error = appError
                self.isLoadingMore = false
            }
        } catch {
            await MainActor.run {
                self.error = .unknown(error)
                self.isLoadingMore = false
            }
        }
    }
}
