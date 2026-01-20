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
    // Mock Data
    let stickers: [Sticker] = [
        Sticker(id: 1, image: .My.red),
        Sticker(id: 2, image: .My.green),
        Sticker(id: 3, image: .My.blue),
        Sticker(id: 4, image: .My.yellow)
    ]
    
    private var cancellables = Set<AnyCancellable>()
    
    private let fetchActivityListUseCase: FetchActivityDropdownListUseCase
    // Initialization
    
    init() {
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
