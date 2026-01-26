//
//  ActivityDetailViewModel.swift
//  Forday
//
//  Created by Subeen on 1/23/26.
//

import Foundation
import Combine

final class ActivityDetailViewModel {

    // MARK: - Published Properties

    @Published var activityDetail: ActivityDetail?
    @Published var isLoading: Bool = false
    @Published var error: AppError?

    // MARK: - Private Properties

    private let activityRecordId: Int
    private let fetchActivityDetailUseCase: FetchActivityDetailUseCase

    // MARK: - Initialization

    init(
        activityRecordId: Int,
        fetchActivityDetailUseCase: FetchActivityDetailUseCase = FetchActivityDetailUseCase()
    ) {
        self.activityRecordId = activityRecordId
        self.fetchActivityDetailUseCase = fetchActivityDetailUseCase
    }

    // MARK: - Public Methods

    func fetchDetail() async {
        await MainActor.run {
            isLoading = true
        }

        do {
            let detail = try await fetchActivityDetailUseCase.execute(activityRecordId: activityRecordId)

            await MainActor.run {
                self.activityDetail = detail
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
}
