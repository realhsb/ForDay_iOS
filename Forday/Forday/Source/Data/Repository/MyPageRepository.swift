//
//  MyPageRepository.swift
//  Forday
//
//  Created by Subeen on 1/23/26.
//

import Foundation

final class MyPageRepository: MyPageRepositoryInterface {

    private let usersService: UsersService
    private let recordsService: RecordsService

    init(usersService: UsersService = UsersService(), recordsService: RecordsService = RecordsService()) {
        self.usersService = usersService
        self.recordsService = recordsService
    }

    func fetchUserProfile() async throws -> UserProfile {
        #if DEBUG
        // API not ready - return mock
        try? await Task.sleep(nanoseconds: 500_000_000) // 0.5s delay
        return makeMockUserProfile()
        #else
        // TODO: Implement API call when ready
        fatalError("API not implemented")
        #endif
    }

    func fetchMyActivities(hobbyId: Int?, lastRecordId: Int?, size: Int) async throws -> MyActivitiesResult {
        // Call real API
        let response = try await usersService.fetchFeeds(
            hobbyId: hobbyId,
            lastRecordId: lastRecordId,
            feedSize: size
        )

        return response.toDomain()
    }

    func fetchMyHobbies() async throws -> [MyPageHobby] {
        #if DEBUG
        // API not ready - return mock
        try? await Task.sleep(nanoseconds: 300_000_000) // 0.3s delay
        return makeMockMyHobbies()
        #else
        // TODO: Implement API call when ready
        fatalError("API not implemented")
        #endif
    }

    func fetchHobbyCards(page: Int) async throws -> [HobbyCardData] {
        #if DEBUG
        // API not ready - return mock
        try? await Task.sleep(nanoseconds: 500_000_000) // 0.5s delay
        return makeMockHobbyCards()
        #else
        // TODO: Implement API call when ready
        fatalError("API not implemented")
        #endif
    }

    func fetchActivityDetail(activityRecordId: Int) async throws -> ActivityDetail {
        let response = try await recordsService.fetchRecordDetail(recordId: activityRecordId)
        return response.toDomain()
    }

    func updateProfile(nickname: String?, profileImageUrl: String?) async throws -> UserProfile {
        #if DEBUG
        // API not ready - return mock
        try? await Task.sleep(nanoseconds: 500_000_000) // 0.5s delay
        return makeMockUpdatedProfile(nickname: nickname, profileImageUrl: profileImageUrl)
        #else
        // TODO: Implement API call when ready
        fatalError("API not implemented")
        #endif
    }
}

// MARK: - Mock Data

#if DEBUG
extension MyPageRepository {

    private func makeMockUserProfile() -> UserProfile {
        UserProfile(
            userId: 1,
            nickname: "유지",
            profileImageUrl: nil,
            totalStickerCount: 14,
            inProgressHobbiesCount: 2
        )
    }

    private func makeMockMyHobbies() -> [MyPageHobby] {
        [
            MyPageHobby(
                hobbyId: 1,
                hobbyName: "독서",
                hobbyIcon: .reading,
                status: .inProgress,
                activityCount: 25
            ),
            MyPageHobby(
                hobbyId: 2,
                hobbyName: "사진촬영",
                hobbyIcon: .photo,
                status: .inProgress,
                activityCount: 17
            ),
            MyPageHobby(
                hobbyId: 3,
                hobbyName: "요리",
                hobbyIcon: .cooking,
                status: .archived,
                activityCount: 8
            )
        ]
    }

    private func makeMockMyActivitiesResult(hobbyId: Int?, page: Int, size: Int) -> MyActivitiesResult {
        let allActivities = makeMockAllActivities()

        // Filter by hobbyId if provided
        let filteredActivities = if let hobbyId = hobbyId {
            allActivities.filter { $0.hobbyId == hobbyId }
        } else {
            allActivities
        }

        // Paginate
        let startIndex = page * size
        let endIndex = min(startIndex + size, filteredActivities.count)

        guard startIndex < filteredActivities.count else {
            return MyActivitiesResult(
                activities: [],
                hasNext: false,
                lastRecordId: nil
            )
        }

        let pageActivities = Array(filteredActivities[startIndex..<endIndex])
        let hasNext = endIndex < filteredActivities.count
        let lastRecordId = hasNext ? pageActivities.last?.activityRecordId : nil

        return MyActivitiesResult(
            activities: pageActivities,
            hasNext: hasNext,
            lastRecordId: lastRecordId
        )
    }

    private func makeMockAllActivities() -> [MyPageActivity] {
        [
            MyPageActivity(
                activityRecordId: 1,
                hobbyId: 1,
                hobbyName: "독서",
                activityContent: "미라클 모닝 아침 독서",
                imageUrl: "https://picsum.photos/300/300?random=1",
                sticker: "😊",
                createdDate: "2026-01-11 12:06",
                memo: "오늘도 아침 6시에 일어나서 독서 끝! 뿌듯한 하루당"
            ),
            MyPageActivity(
                activityRecordId: 2,
                hobbyId: 2,
                hobbyName: "사진촬영",
                activityContent: "아침 산책 길에 본 풍경",
                imageUrl: "https://picsum.photos/300/300?random=2",
                sticker: "🌅",
                createdDate: "2026-01-12 08:30",
                memo: "아침 햇살이 정말 예뻤다"
            ),
            MyPageActivity(
                activityRecordId: 3,
                hobbyId: 1,
                hobbyName: "독서",
                activityContent: "점심 시간에 읽는 소설",
                imageUrl: "https://picsum.photos/300/300?random=3",
                sticker: "📖",
                createdDate: "2026-01-13 13:00",
                memo: nil
            ),
            MyPageActivity(
                activityRecordId: 4,
                hobbyId: 2,
                hobbyName: "사진촬영",
                activityContent: "카페에서 본 라떼아트",
                imageUrl: "https://picsum.photos/300/300?random=4",
                sticker: "☕",
                createdDate: "2026-01-14 15:20",
                memo: "라떼가 너무 예뻐서 사진 찍었다"
            ),
            MyPageActivity(
                activityRecordId: 5,
                hobbyId: 1,
                hobbyName: "독서",
                activityContent: "저녁 독서 시간",
                imageUrl: "https://picsum.photos/300/300?random=5",
                sticker: "🌙",
                createdDate: "2026-01-15 20:00",
                memo: "잠들기 전 30분 독서"
            ),
            MyPageActivity(
                activityRecordId: 6,
                hobbyId: 2,
                hobbyName: "사진촬영",
                activityContent: "주말 나들이",
                imageUrl: "https://picsum.photos/300/300?random=6",
                sticker: "🌸",
                createdDate: "2026-01-16 14:00",
                memo: nil
            ),
            MyPageActivity(
                activityRecordId: 7,
                hobbyId: 1,
                hobbyName: "독서",
                activityContent: "도서관에서 책 읽기",
                imageUrl: "https://picsum.photos/300/300?random=7",
                sticker: "📚",
                createdDate: "2026-01-17 11:00",
                memo: "조용한 도서관이 최고"
            ),
            MyPageActivity(
                activityRecordId: 8,
                hobbyId: 2,
                hobbyName: "사진촬영",
                activityContent: "저녁 노을",
                imageUrl: "https://picsum.photos/300/300?random=8",
                sticker: "🌆",
                createdDate: "2026-01-18 18:30",
                memo: "오늘 노을이 정말 예쁘다"
            ),
            MyPageActivity(
                activityRecordId: 9,
                hobbyId: 1,
                hobbyName: "독서",
                activityContent: "출근길 지하철 독서",
                imageUrl: "https://picsum.photos/300/300?random=9",
                sticker: "🚇",
                createdDate: "2026-01-19 08:00",
                memo: nil
            ),
            MyPageActivity(
                activityRecordId: 10,
                hobbyId: 2,
                hobbyName: "사진촬영",
                activityContent: "맛있는 점심",
                imageUrl: "https://picsum.photos/300/300?random=10",
                sticker: "🍜",
                createdDate: "2026-01-20 12:30",
                memo: "오늘 점심 메뉴가 정말 맛있었다"
            ),
            MyPageActivity(
                activityRecordId: 11,
                hobbyId: 1,
                hobbyName: "독서",
                activityContent: "퇴근 후 독서",
                imageUrl: "https://picsum.photos/300/300?random=11",
                sticker: "😌",
                createdDate: "2026-01-21 19:00",
                memo: "피곤하지만 책을 읽으니 마음이 편안해진다"
            ),
            MyPageActivity(
                activityRecordId: 12,
                hobbyId: 2,
                hobbyName: "사진촬영",
                activityContent: "아침 커피 한 잔",
                imageUrl: "https://picsum.photos/300/300?random=12",
                sticker: "☕",
                createdDate: "2026-01-22 07:30",
                memo: nil
            ),
        ]
    }

    private func makeMockHobbyCards() -> [HobbyCardData] {
        [
            HobbyCardData(
                cardId: 1,
                imageUrl: "https://picsum.photos/400/600?random=101",
                text: "주로 아침에 활동한 독서",
                hobbyName: "독서"
            ),
            HobbyCardData(
                cardId: 2,
                imageUrl: "https://picsum.photos/400/600?random=102",
                text: "매일 10분 산책으로 찍은 사진들",
                hobbyName: "사진촬영"
            ),
            HobbyCardData(
                cardId: 3,
                imageUrl: "https://picsum.photos/400/600?random=103",
                text: "저녁마다 요리하는 즐거움",
                hobbyName: "요리"
            ),
            HobbyCardData(
                cardId: 4,
                imageUrl: "https://picsum.photos/400/600?random=104",
                text: "책 한 페이지씩 읽는 습관",
                hobbyName: "독서"
            ),
            HobbyCardData(
                cardId: 5,
                imageUrl: "https://picsum.photos/400/600?random=105",
                text: "일상 속 작은 순간들",
                hobbyName: "사진촬영"
            ),
        ]
    }

    private func makeMockActivityDetail(activityRecordId: Int) -> ActivityDetail {
        // Find activity from mock data
        let allActivities = makeMockAllActivities()
        let activity = allActivities.first { $0.activityRecordId == activityRecordId }
            ?? allActivities[0]

        return ActivityDetail(
            activityRecordId: activity.activityRecordId,
            activityId: 1,
            activityContent: activity.activityContent,
            imageUrl: activity.imageUrl,
            sticker: activity.sticker,
            createdAt: activity.createdDate,
            memo: activity.memo ?? "",
            recordOwner: true,
            visibility: "PUBLIC",
            newReaction: ReactionStatus(awesome: false, great: false, amazing: false, fighting: false),
            userReaction: ReactionStatus(awesome: true, great: true, amazing: false, fighting: false)
        )
    }

    private func makeMockUpdatedProfile(nickname: String?, profileImageUrl: String?) -> UserProfile {
        var profile = makeMockUserProfile()

        return UserProfile(
            userId: profile.userId,
            nickname: nickname ?? profile.nickname,
            profileImageUrl: profileImageUrl ?? profile.profileImageUrl,
            totalStickerCount: profile.totalStickerCount,
            inProgressHobbiesCount: profile.inProgressHobbiesCount
        )
    }
}
#endif
