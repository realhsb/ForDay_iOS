//
//  StickerBoardViewModel.swift
//  Forday
//
//  Created by Subeen on 1/23/26.
//

import Foundation
import Combine

final class StickerBoardViewModel {

    // MARK: - Published Properties

    @Published var viewState: ViewState = .loading
    @Published var stickerBoard: StickerBoard?
    @Published var errorMessage: String?

    // MARK: - Private Properties

    private let fetchStickerBoardUseCase: FetchStickerBoardUseCase
    private var cancellables = Set<AnyCancellable>()

    // MARK: - Navigation Callbacks

    var onNavigateToActivityDetail: ((Int) -> Void)? // (activityRecordId)

    // MARK: - Initialization

    init(fetchStickerBoardUseCase: FetchStickerBoardUseCase = FetchStickerBoardUseCase()) {
        self.fetchStickerBoardUseCase = fetchStickerBoardUseCase
    }

    // MARK: - Private Properties

    private var currentHobbyId: Int?

    // MARK: - Public Methods

    /// 초기 로드: 페이지 번호 없이 조회 (마지막 페이지 반환)
    func loadInitialStickerBoard(hobbyId: Int? = nil) async {
        if let hobbyId = hobbyId {
            currentHobbyId = hobbyId
        }
        await loadStickerBoard(page: nil)
    }

    /// 특정 페이지 로드
    func loadPage(_ page: Int) async {
        await loadStickerBoard(page: page)
    }

    /// 이전 페이지로 이동
    func loadPreviousPage() async {
        guard let board = stickerBoard, board.hasPrevious else { return }
        await loadStickerBoard(page: board.currentPage - 1)
    }

    /// 다음 페이지로 이동
    func loadNextPage() async {
        guard let board = stickerBoard, board.hasNext else { return }
        await loadStickerBoard(page: board.currentPage + 1)
    }

    /// 스티커 탭 처리
    func didTapSticker(at index: Int) {
        guard let board = stickerBoard else { return }

        // 핑크 외곽선 스티커 (오늘 기록 안 함)
        if index == 0 && !board.activityRecordedToday {
            navigateToActivityRecord()
            return
        }

        // 이미 채워진 스티커
        if index < board.stickers.count {
            let sticker = board.stickers[index]
            navigateToActivityDetail(activityRecordId: sticker.activityRecordId)
        }

        // 회색 빈 스티커는 아무 동작 없음
    }

    // MARK: - Private Methods

    private func loadStickerBoard(page: Int?) async {
        await MainActor.run {
            self.viewState = .loading
        }

        do {
            let result = try await fetchStickerBoardUseCase.execute(hobbyId: currentHobbyId, page: page)

            await MainActor.run {
                switch result {
                case .loaded(let board):
                    self.stickerBoard = board
                    self.viewState = .loaded

                case .noHobbyInProgress:
                    self.stickerBoard = nil
                    self.viewState = .noHobby

                case .emptyBoard(let board):
                    self.stickerBoard = board
                    self.viewState = .empty
                }
            }
        } catch {
            await MainActor.run {
                self.errorMessage = error.localizedDescription
                self.viewState = .error
            }
        }
    }

    private func navigateToActivityRecord() {
        // TODO: 활동 기록 화면으로 이동
        print("🎯 Navigate to Activity Record")
    }

    private func navigateToActivityDetail(activityRecordId: Int) {
        print("🎯 Navigate to Activity Detail: \(activityRecordId)")
        onNavigateToActivityDetail?(activityRecordId)
    }

    // MARK: - View State

    enum ViewState {
        case loading
        case loaded
        case noHobby
        case empty
        case error
    }
}
