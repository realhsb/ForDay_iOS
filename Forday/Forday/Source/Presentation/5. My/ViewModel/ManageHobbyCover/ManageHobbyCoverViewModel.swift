//
//  ManageHobbyCoverViewModel.swift
//  Forday
//
//  Created by Subeen on 1/27/26.
//

import Foundation
import UIKit
import Combine

class ManageHobbyCoverViewModel {

    // MARK: - Published Properties

    @Published var hobbies: [MyPageHobby] = []
    @Published var feedItems: [FeedItem] = []
    @Published var selectedHobbyId: Int? = nil
    @Published var isSelectionMode: Bool = false
    @Published var selectedRecordId: Int? = nil
    @Published var error: AppError?
    @Published var isLoading: Bool = false

    private var cancellables = Set<AnyCancellable>()

    // MARK: - Repositories

    private let usersRepository: UsersRepositoryInterface
    private let hobbyRepository: HobbyRepositoryInterface

    // MARK: - Initialization

    init(
        usersRepository: UsersRepositoryInterface = UsersRepository(),
        hobbyRepository: HobbyRepositoryInterface = HobbyRepository()
    ) {
        self.usersRepository = usersRepository
        self.hobbyRepository = hobbyRepository
    }

    // MARK: - Methods

    /// 취미 리스트 설정
    func setHobbies(_ hobbies: [MyPageHobby]) {
        self.hobbies = hobbies
    }

    /// 전체 피드 조회 (초기 로드)
    func fetchAllFeeds() async {
        await fetchFeeds(hobbyId: nil)
    }

    /// 특정 취미의 피드 조회
    func fetchFeeds(hobbyId: Int?) async {
        await MainActor.run {
            self.isLoading = true
        }

        do {
            let result = try await usersRepository.fetchFeeds(
                hobbyId: hobbyId,
                lastRecordId: nil,
                feedSize: 100
            )

            await MainActor.run {
                self.feedItems = result.feedList
                self.isLoading = false
            }
        } catch let appError as AppError {
            await MainActor.run {
                self.error = appError
                self.feedItems = []
                self.isLoading = false
            }
        } catch {
            await MainActor.run {
                self.error = .unknown(error)
                self.feedItems = []
                self.isLoading = false
            }
        }
    }

    /// 취미 선택 (카메라 아이콘이 아닌 취미 자체 선택)
    func selectHobby(_ hobbyId: Int) {
        self.selectedHobbyId = hobbyId
        Task {
            await fetchFeeds(hobbyId: hobbyId)
        }
    }

    /// 선택 모드 시작 (카메라 아이콘 → 바텀시트 → "내 활동 중 사진 선택")
    func enterSelectionMode(forHobbyId hobbyId: Int) {
        self.selectedHobbyId = hobbyId
        self.isSelectionMode = true
        self.selectedRecordId = nil

        // 해당 취미의 피드만 로드
        Task {
            await fetchFeeds(hobbyId: hobbyId)
        }
    }

    /// 선택 모드 취소
    func cancelSelectionMode() {
        self.isSelectionMode = false
        self.selectedRecordId = nil
        self.selectedHobbyId = nil

        // 전체 피드 다시 로드
        Task {
            await fetchAllFeeds()
        }
    }

    /// 활동 기록 선택/해제
    func toggleFeedItemSelection(_ recordId: Int) {
        if selectedRecordId == recordId {
            selectedRecordId = nil
        } else {
            selectedRecordId = recordId
        }
    }

    /// 갤러리에서 이미지 선택하여 대표사진 변경
    func updateCoverImageWithGallery(hobbyId: Int, image: UIImage) async throws -> String {
        // 1. Presigned URL 발급 (COVER_IMAGE)
        let presignedResult = try await usersRepository.updateProfileImage(profileImageUrl: "temp")

        // TODO: S3 업로드 구현 필요
        // 2. S3에 이미지 업로드

        // 3. API 호출: { hobbyId, coverImageUrl, recordId: null }
        let result = try await hobbyRepository.updateCoverImage(
            hobbyId: hobbyId,
            coverImageUrl: "uploaded-url", // TODO: 실제 업로드된 URL
            recordId: nil
        )

        return result.message
    }

    /// 활동 기록에서 선택하여 대표사진 변경
    func updateCoverImageWithRecord() async throws -> String {
        guard let recordId = selectedRecordId else {
            throw AppError.unknown(NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "선택된 활동 기록이 없습니다"]))
        }

        // API 호출: { hobbyId: null, coverImageUrl: null, recordId }
        let result = try await hobbyRepository.updateCoverImage(
            hobbyId: nil,
            coverImageUrl: nil,
            recordId: recordId
        )

        return result.message
    }
}
