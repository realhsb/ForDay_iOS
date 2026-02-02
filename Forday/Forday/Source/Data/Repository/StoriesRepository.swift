//
//  StoriesRepository.swift
//  Forday
//
//  Created by Subeen on 2/1/26.
//

import Foundation

final class StoriesRepository: StoriesRepositoryInterface {

    private let storiesService: StoriesService

    init(storiesService: StoriesService = StoriesService()) {
        self.storiesService = storiesService
    }

    // MARK: - Fetch Stories Tabs

    func fetchStoriesTabs() async throws -> [StoriesTab] {
        do {
            let response = try await storiesService.fetchStoriesTabs()
            return response.toDomain()
        } catch {
            #if DEBUG
            print("⚠️ Stories Tabs API 실패 - 목 데이터 사용")
            print("⚠️ 에러 내용: \(error)")
            return makeMockTabs()
            #else
            throw error
            #endif
        }
    }

    // MARK: - Fetch Stories

    func fetchStories(
        hobbyId: Int?,
        lastRecordId: Int?,
        size: Int,
        keyword: String?
    ) async throws -> StoriesResult? {
        do {
            let response = try await storiesService.fetchStories(
                hobbyId: hobbyId,
                lastRecordId: lastRecordId,
                size: size,
                keyword: keyword
            )
            return response.toDomain()
        } catch {
            #if DEBUG
            print("⚠️ Stories API 실패 - 목 데이터 사용")
            print("⚠️ 에러 내용: \(error)")
            return makeMockStories(hobbyId: hobbyId, lastRecordId: lastRecordId, size: size)
            #else
            throw error
            #endif
        }
    }
}

// MARK: - Mock Data

#if DEBUG
extension StoriesRepository {
    private func makeMockTabs() -> [StoriesTab] {
        return [
            StoriesTab(hobbyId: 1, hobbyName: "독서", hobbyStatus: "IN_PROGRESS"),
            StoriesTab(hobbyId: 2, hobbyName: "운동", hobbyStatus: "IN_PROGRESS"),
            StoriesTab(hobbyId: 3, hobbyName: "요리", hobbyStatus: "COMPLETED")
        ]
    }

    private func makeMockStories(hobbyId: Int?, lastRecordId: Int?, size: Int) -> StoriesResult {
        let mockStories: [Story] = [
            Story(
                recordId: 1,
                thumbnailUrl: "https://picsum.photos/200/300",
                stickerType: .angry,
                title: "아침 독서로 하루를 시작했어요",
                memo: "오늘은 미라클 모닝으로 독서를 했습니다. 정말 좋은 하루의 시작이었어요!",
                userInfo: StoryUserInfo(
                    userId: "user1",
                    nickname: "포비",
                    profileImageUrl: "https://picsum.photos/100/100"
                ),
                pressedAwesome: false
            ),
            Story(
                recordId: 2,
                thumbnailUrl: nil,
                stickerType: .laugh,
                title: "새로운 레시피에 도전!",
                memo: "파스타를 처음 만들어봤는데 생각보다 맛있게 나왔어요. 다음엔 더 잘 만들 수 있을 것 같아요.",
                userInfo: StoryUserInfo(
                    userId: "user2",
                    nickname: "크롱",
                    profileImageUrl: nil
                ),
                pressedAwesome: true
            ),
            Story(
                recordId: 3,
                thumbnailUrl: "https://picsum.photos/200/250",
                stickerType: .sad,
                title: "운동 3일차 달성!",
                memo: nil,
                userInfo: StoryUserInfo(
                    userId: "user3",
                    nickname: "코난",
                    profileImageUrl: "https://picsum.photos/100/101"
                ),
                pressedAwesome: false
            ),
            Story(
                recordId: 4,
                thumbnailUrl: nil,
                stickerType: .smile,
                title: "명상으로 마음의 평화를",
                memo: "10분간의 명상으로 하루를 마무리했습니다. 정말 차분해지는 느낌이에요.",
                userInfo: StoryUserInfo(
                    userId: "user4",
                    nickname: "제이슨",
                    profileImageUrl: "https://picsum.photos/100/102"
                ),
                pressedAwesome: true
            ),
            Story(
                recordId: 5,
                thumbnailUrl: "https://picsum.photos/200/280",
                stickerType: .smile,
                title: "주말 등산 다녀왔어요",
                memo: "북한산 등산 다녀왔습니다. 날씨가 너무 좋았어요!",
                userInfo: StoryUserInfo(
                    userId: "user5",
                    nickname: "브라운",
                    profileImageUrl: nil
                ),
                pressedAwesome: false
            ),
            Story(
                recordId: 6,
                thumbnailUrl: "https://picsum.photos/200/320",
                stickerType: .smile,
                title: "드로잉 연습 중",
                memo: nil,
                userInfo: StoryUserInfo(
                    userId: "user6",
                    nickname: "샐리",
                    profileImageUrl: "https://picsum.photos/100/103"
                ),
                pressedAwesome: true
            ),
            Story(
                recordId: 7,
                thumbnailUrl: nil,
                stickerType: .smile,
                title: "영어 공부 30분 완료",
                memo: "오늘은 영어 팟캐스트를 들으며 공부했어요. 듣기 실력이 늘고 있는 것 같아요.",
                userInfo: StoryUserInfo(
                    userId: "user7",
                    nickname: "문",
                    profileImageUrl: "https://picsum.photos/100/104"
                ),
                pressedAwesome: false
            ),
            Story(
                recordId: 8,
                thumbnailUrl: "https://picsum.photos/200/290",
                stickerType: .smile,
                title: "카페에서 코딩 공부",
                memo: nil,
                userInfo: StoryUserInfo(
                    userId: "user8",
                    nickname: "레너드",
                    profileImageUrl: nil
                ),
                pressedAwesome: true
            )
        ]

        // Pagination simulation based on recordId
        let filteredStories: [Story]
        if let lastRecordId = lastRecordId {
            // Find stories with recordId > lastRecordId
            filteredStories = mockStories.filter { $0.recordId > lastRecordId }
        } else {
            // First page, return all stories
            filteredStories = mockStories
        }

        // Take only 'size' items
        let paginatedStories = Array(filteredStories.prefix(size))

        // Determine if there are more items
        let hasNext = filteredStories.count > size
        let nextLastRecordId = hasNext ? paginatedStories.last?.recordId : nil

        return StoriesResult(
            hobbyInfoId: 1,
            hobbyId: hobbyId ?? 1,
            hobbyName: "독서",
            stories: paginatedStories,
            lastRecordId: nextLastRecordId,
            hasNext: hasNext
        )
    }
}
#endif
