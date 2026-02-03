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

    func fetchUserInfo() async throws -> UserInfo {
        let response = try await usersService.fetchUserInfo()

        return response.toDomain()
    }

    func fetchMyHobbies() async throws -> MyHobbiesResult {
        let response = try await usersService.fetchHobbiesInProgress()
        return response.toDomain()
    }

    func fetchActivityDetail(activityRecordId: Int) async throws -> ActivityDetail {
        let response = try await recordsService.fetchRecordDetail(recordId: activityRecordId)
        return response.toDomain()
    }

    func updateProfile(nickname: String, profileImageUrl: String) async throws -> UserInfo {
        #if DEBUG
        // API not ready - return mock
        try? await Task.sleep(nanoseconds: 500_000_000) // 0.5s delay
        return makeMockUpdatedProfile(nickname: nickname, profileImageUrl: profileImageUrl)
        #else
        // TODO: Implement API call when ready
        fatalError("API not implemented")
        #endif
    }

    func addReaction(recordId: Int, reactionType: ReactionType) async throws -> AddReactionResult {
        let response = try await recordsService.addReaction(recordId: recordId, reactionType: reactionType)
        return response.toDomain()
    }

    func deleteReaction(recordId: Int, reactionType: ReactionType) async throws -> DeleteReactionResult {
        let response = try await recordsService.deleteReaction(recordId: recordId, reactionType: reactionType)
        return response.toDomain()
    }

    func fetchReactionUsers(recordId: Int, reactionType: ReactionType, lastUserId: String?, size: Int) async throws -> FetchReactionUsersResult {
        let response = try await recordsService.fetchReactionUsers(
            recordId: recordId,
            reactionType: reactionType,
            lastUserId: lastUserId,
            size: size
        )
        return response.toDomain()
    }

    func addScrap(recordId: Int) async throws -> ScrapResult {
        let response = try await recordsService.addScrap(recordId: recordId)
        return response.toDomain()
    }

    func deleteScrap(recordId: Int) async throws -> ScrapResult {
        let response = try await recordsService.deleteScrap(recordId: recordId)
        return response.toDomain()
    }
}

// MARK: - Mock Data

#if DEBUG
extension MyPageRepository {

//    private func makeMockMyActivitiesResult(hobbyId: Int?, page: Int, size: Int) -> FeedResult {
//        let allActivities = makeMockAllActivities()
//
//        // Filter by hobbyId if provided
//        let filteredActivities = if let hobbyId = hobbyId {
//            allActivities.filter { $0.hobbyId == hobbyId }
//        } else {
//            allActivities
//        }
//
//        // Paginate
//        let startIndex = page * size
//        let endIndex = min(startIndex + size, filteredActivities.count)
//
//        guard startIndex < filteredActivities.count else {
//            return FeedResult(
//                activities: [],
//                hasNext: false,
//                lastRecordId: nil
//            )
//        }
//
//        let pageActivities = Array(filteredActivities[startIndex..<endIndex])
//        let hasNext = endIndex < filteredActivities.count
//        let lastRecordId = hasNext ? pageActivities.last?.activityRecordId : nil
//
//        return MyActivitiesResult(
//            activities: pageActivities,
//            hasNext: hasNext,
//            lastRecordId: lastRecordId
//        )
//    }

//    private func makeMockAllActivities() -> [MyPageActivity] {
//        [
//            MyPageActivity(
//                activityRecordId: 1,
//                hobbyId: 1,
//                hobbyName: "독서",
//                activityContent: "미라클 모닝 아침 독서",
//                imageUrl: "https://picsum.photos/300/300?random=1",
//                sticker: "😊",
//                createdDate: "2026-01-11 12:06",
//                memo: "오늘도 아침 6시에 일어나서 독서 끝! 뿌듯한 하루당"
//            ),
//            MyPageActivity(
//                activityRecordId: 2,
//                hobbyId: 2,
//                hobbyName: "사진촬영",
//                activityContent: "아침 산책 길에 본 풍경",
//                imageUrl: "https://picsum.photos/300/300?random=2",
//                sticker: "🌅",
//                createdDate: "2026-01-12 08:30",
//                memo: "아침 햇살이 정말 예뻤다"
//            ),
//            MyPageActivity(
//                activityRecordId: 3,
//                hobbyId: 1,
//                hobbyName: "독서",
//                activityContent: "점심 시간에 읽는 소설",
//                imageUrl: "https://picsum.photos/300/300?random=3",
//                sticker: "📖",
//                createdDate: "2026-01-13 13:00",
//                memo: nil
//            ),
//            MyPageActivity(
//                activityRecordId: 4,
//                hobbyId: 2,
//                hobbyName: "사진촬영",
//                activityContent: "카페에서 본 라떼아트",
//                imageUrl: "https://picsum.photos/300/300?random=4",
//                sticker: "☕",
//                createdDate: "2026-01-14 15:20",
//                memo: "라떼가 너무 예뻐서 사진 찍었다"
//            ),
//            MyPageActivity(
//                activityRecordId: 5,
//                hobbyId: 1,
//                hobbyName: "독서",
//                activityContent: "저녁 독서 시간",
//                imageUrl: "https://picsum.photos/300/300?random=5",
//                sticker: "🌙",
//                createdDate: "2026-01-15 20:00",
//                memo: "잠들기 전 30분 독서"
//            ),
//            MyPageActivity(
//                activityRecordId: 6,
//                hobbyId: 2,
//                hobbyName: "사진촬영",
//                activityContent: "주말 나들이",
//                imageUrl: "https://picsum.photos/300/300?random=6",
//                sticker: "🌸",
//                createdDate: "2026-01-16 14:00",
//                memo: nil
//            ),
//            MyPageActivity(
//                activityRecordId: 7,
//                hobbyId: 1,
//                hobbyName: "독서",
//                activityContent: "도서관에서 책 읽기",
//                imageUrl: "https://picsum.photos/300/300?random=7",
//                sticker: "📚",
//                createdDate: "2026-01-17 11:00",
//                memo: "조용한 도서관이 최고"
//            ),
//            MyPageActivity(
//                activityRecordId: 8,
//                hobbyId: 2,
//                hobbyName: "사진촬영",
//                activityContent: "저녁 노을",
//                imageUrl: "https://picsum.photos/300/300?random=8",
//                sticker: "🌆",
//                createdDate: "2026-01-18 18:30",
//                memo: "오늘 노을이 정말 예쁘다"
//            ),
//            MyPageActivity(
//                activityRecordId: 9,
//                hobbyId: 1,
//                hobbyName: "독서",
//                activityContent: "출근길 지하철 독서",
//                imageUrl: "https://picsum.photos/300/300?random=9",
//                sticker: "🚇",
//                createdDate: "2026-01-19 08:00",
//                memo: nil
//            ),
//            MyPageActivity(
//                activityRecordId: 10,
//                hobbyId: 2,
//                hobbyName: "사진촬영",
//                activityContent: "맛있는 점심",
//                imageUrl: "https://picsum.photos/300/300?random=10",
//                sticker: "🍜",
//                createdDate: "2026-01-20 12:30",
//                memo: "오늘 점심 메뉴가 정말 맛있었다"
//            ),
//            MyPageActivity(
//                activityRecordId: 11,
//                hobbyId: 1,
//                hobbyName: "독서",
//                activityContent: "퇴근 후 독서",
//                imageUrl: "https://picsum.photos/300/300?random=11",
//                sticker: "😌",
//                createdDate: "2026-01-21 19:00",
//                memo: "피곤하지만 책을 읽으니 마음이 편안해진다"
//            ),
//            MyPageActivity(
//                activityRecordId: 12,
//                hobbyId: 2,
//                hobbyName: "사진촬영",
//                activityContent: "아침 커피 한 잔",
//                imageUrl: "https://picsum.photos/300/300?random=12",
//                sticker: "☕",
//                createdDate: "2026-01-22 07:30",
//                memo: nil
//            ),
//        ]
//    }
//
//    private func makeMockActivityDetail(activityRecordId: Int) -> ActivityDetail {
//        // Find activity from mock data
//        let allActivities = makeMockAllActivities()
//        let activity = allActivities.first { $0.activityRecordId == activityRecordId }
//            ?? allActivities[0]
//
//        return ActivityDetail(
//            activityRecordId: activity.activityRecordId,
//            activityId: 1,
//            activityContent: activity.activityContent,
//            imageUrl: activity.imageUrl,
//            sticker: activity.sticker,
//            createdAt: activity.createdDate,
//            memo: activity.memo ?? "",
//            recordOwner: true,
//            visibility: "PUBLIC",
//            newReaction: ReactionStatus(awesome: false, great: false, amazing: false, fighting: false),
//            userReaction: ReactionStatus(awesome: true, great: true, amazing: false, fighting: false)
//        )
//    }

    private func makeMockUpdatedProfile(nickname: String, profileImageUrl: String) -> UserInfo {
        return UserInfo(
            profileImageUrl: profileImageUrl,
            nickname: nickname,
            totalCollectedStickerCount: 1
        )
    }
}
#endif
