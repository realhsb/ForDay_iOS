//
//  ActivityWriteViewModel.swift
//  Forday
//
//  Created by Subeen on 1/15/26.
//


import Foundation
import Combine
import UIKit

class ActivityWriteViewModel {

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

    private let hobbyId: Int

    // Initialization

    init(
        hobbyId: Int,
        fetchActivityListUseCase: FetchActivityDropdownListUseCase = FetchActivityDropdownListUseCase(),
        uploadImageUseCase: UploadImageUseCase = UploadImageUseCase(),
        deleteImageUseCase: DeleteImageUseCase = DeleteImageUseCase()
    ) {
        self.hobbyId = hobbyId
        self.fetchActivityListUseCase = fetchActivityListUseCase
        self.uploadImageUseCase = uploadImageUseCase
        self.deleteImageUseCase = deleteImageUseCase
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

enum Privacy {
    case `public`
    case friends
    case `private`
    
    var title: String {
        switch self {
        case .public: return "전체공개"
        case .friends: return "친구공개"
        case .private: return "나만보기"
        }
    }
}
