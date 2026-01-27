//
//  ManageHobbyCoverViewModel.swift
//  Forday
//
//  Created by Subeen on 1/27/26.
//

import Foundation
import UIKit
import Combine

enum CoverImageSource {
    case gallery
    case activityRecord
}

class ManageHobbyCoverViewModel {

    // MARK: - Published Properties

    @Published var hobbies: [MyPageHobby] = []
    @Published var selectedHobby: MyPageHobby?
    @Published var activityRecords: [StickerBoardItem] = []
    @Published var selectedRecordId: Int?
    @Published var error: AppError?
    @Published var isLoading: Bool = false

    private var cancellables = Set<AnyCancellable>()

    // MARK: - UseCases

    private let fetchStickerBoardUseCase: FetchStickerBoardUseCase
    private let updateHobbyCoverUseCase: UpdateHobbyCoverUseCase

    // MARK: - Initialization

    init(
        fetchStickerBoardUseCase: FetchStickerBoardUseCase = FetchStickerBoardUseCase(),
        updateHobbyCoverUseCase: UpdateHobbyCoverUseCase = UpdateHobbyCoverUseCase()
    ) {
        self.fetchStickerBoardUseCase = fetchStickerBoardUseCase
        self.updateHobbyCoverUseCase = updateHobbyCoverUseCase
        bind()
    }

    // MARK: - Methods

    private func bind() {
        // 취미 선택 시 활동 기록 자동 로드
        $selectedHobby
            .compactMap { $0 }
            .sink { [weak self] hobby in
                Task {
                    await self?.fetchActivityRecords(for: hobby.hobbyId)
                }
            }
            .store(in: &cancellables)
    }

    /// 취미 리스트 설정
    func setHobbies(_ hobbies: [MyPageHobby]) {
        self.hobbies = hobbies
        if let firstHobby = hobbies.first {
            self.selectedHobby = firstHobby
        }
    }

    /// 특정 취미의 활동 기록 조회
    func fetchActivityRecords(for hobbyId: Int) async {
        await MainActor.run {
            self.isLoading = true
        }

        do {
            let result = try await fetchStickerBoardUseCase.execute(hobbyId: hobbyId, page: nil, size: nil)

            await MainActor.run {
                switch result {
                case .loaded(let board):
                    self.activityRecords = board.stickers
                case .emptyBoard:
                    self.activityRecords = []
                case .noHobbyInProgress:
                    self.activityRecords = []
                }
                self.isLoading = false
            }
        } catch let appError as AppError {
            await MainActor.run {
                self.error = appError
                self.activityRecords = []
                self.isLoading = false
            }
        } catch {
            await MainActor.run {
                self.error = .unknown(error)
                self.activityRecords = []
                self.isLoading = false
            }
        }
    }

    /// 갤러리에서 이미지 선택하여 대표사진 변경
    func updateCoverImageWithGallery(image: UIImage) async throws -> String {
        guard let hobbyId = selectedHobby?.hobbyId else {
            throw CoverImageError.uploadFailed
        }

        let result = try await updateHobbyCoverUseCase.executeWithImage(hobbyId: hobbyId, image: image)
        return result.message
    }

    /// 활동 기록에서 선택하여 대표사진 변경
    func updateCoverImageWithRecord() async throws -> String {
        guard let recordId = selectedRecordId else {
            throw CoverImageError.uploadFailed
        }

        let result = try await updateHobbyCoverUseCase.executeWithRecord(recordId: recordId)
        return result.message
    }

    /// 활동 기록 선택/해제
    func toggleRecordSelection(_ recordId: Int) {
        if selectedRecordId == recordId {
            selectedRecordId = nil
        } else {
            selectedRecordId = recordId
        }
    }
}
