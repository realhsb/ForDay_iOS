//
//  ActivityWriteViewModel.swift
//  Forday
//
//  Created by Subeen on 1/15/26.
//


import Foundation
import Combine
import UIKit

class ActivityRecordViewModel {

    // Published Properties

    @Published var selectedActivity: Activity?
    @Published var selectedSticker: Sticker?
    @Published var memo: String = ""
    @Published var privacy: Privacy = .public
    @Published var isSubmitEnabled: Bool = false
    @Published var activities: [Activity] = []
    @Published var uploadedImageUrl: String?
    @Published var selectedImage: UIImage?

    // Mock Data
    let stickers: [Sticker] = [
        Sticker(id: 1, image: .My.red),
        Sticker(id: 2, image: .My.green),
        Sticker(id: 3, image: .My.blue),
        Sticker(id: 4, image: .My.yellow)
    ]

    private var cancellables = Set<AnyCancellable>()

    // UseCase
    private let fetchActivityListUseCase: FetchActivityDropdownListUseCase
    private let uploadImageUseCase: UploadImageUseCase
    private let deleteImageUseCase: DeleteImageUseCase
    private let createActivityRecordUseCase: CreateActivityRecordUseCase

    private let hobbyId: Int

    // Initialization

    init(
        hobbyId: Int,
        fetchActivityListUseCase: FetchActivityDropdownListUseCase = FetchActivityDropdownListUseCase(),
        uploadImageUseCase: UploadImageUseCase = UploadImageUseCase(),
        deleteImageUseCase: DeleteImageUseCase = DeleteImageUseCase(),
        createActivityRecordUseCase: CreateActivityRecordUseCase = CreateActivityRecordUseCase()
    ) {
        self.hobbyId = hobbyId
        self.fetchActivityListUseCase = fetchActivityListUseCase
        self.uploadImageUseCase = uploadImageUseCase
        self.deleteImageUseCase = deleteImageUseCase
        self.createActivityRecordUseCase = createActivityRecordUseCase
        bind()
    }

    // Methods

    private func bind() {
        Publishers.CombineLatest($selectedActivity, $selectedSticker)
            .sink { [weak self] activity, sticker in
                self?.isSubmitEnabled = activity != nil && sticker != nil
            }
            .store(in: &cancellables)
    }

    func selectSticker(_ sticker: Sticker) {
        selectedSticker = sticker
    }

    func fetchActivityList() async throws {
        let fetchedActivities = try await fetchActivityListUseCase.execute(hobbyId: hobbyId)
        await MainActor.run {
            self.activities = fetchedActivities
        }
    }

    func selectActivity(_ activity: Activity) {
        selectedActivity = activity
    }

    func selectPrivacy(_ selectedPrivacy: Privacy) {
        privacy = selectedPrivacy
    }

    func updateMemo(_ text: String) {
        memo = text
    }

    func uploadImage(_ image: UIImage) async throws {
        let imageUrls = try await uploadImageUseCase.execute(images: [(image: image, usage: .activityRecord)])
        await MainActor.run {
            if let firstUrl = imageUrls.first {
                self.uploadedImageUrl = firstUrl
                self.selectedImage = image
            }
        }
    }

    func deleteImage() async throws {
        guard let imageUrl = uploadedImageUrl else { return }
        _ = try await deleteImageUseCase.execute(imageUrl: imageUrl)
        await MainActor.run {
            self.uploadedImageUrl = nil
            self.selectedImage = nil
        }
    }

    func submitActivityRecord() async throws -> ActivityRecord {
        guard let activityId = selectedActivity?.activityId,
              let selectedSticker = selectedSticker else {
            throw ActivityRecordError.missingRequiredFields
        }

        // sticker.image를 파일명으로 변환 (실제로는 스티커 파일명을 사용)
        // 현재는 mock data이므로 임시로 "smile.jpg" 사용
        let stickerFileName = "smile.jpg"

        return try await createActivityRecordUseCase.execute(
            activityId: activityId,
            sticker: stickerFileName,
            memo: memo.isEmpty ? nil : memo,
            imageUrl: uploadedImageUrl,
            visibility: privacy
        )
    }
}

enum ActivityRecordError: Error {
    case missingRequiredFields
}

// Models

struct Sticker {
    let id: Int
    let image: UIImage
}

extension Sticker: Equatable {
    static func == (lhs: Sticker, rhs: Sticker) -> Bool {
        return lhs.id == rhs.id
    }
}
