//
//  UpdateHobbyCoverUseCase.swift
//  Forday
//
//  Created by Subeen on 1/27/26.
//

import Foundation
import UIKit

final class UpdateHobbyCoverUseCase {

    private let hobbyRepository: HobbyRepositoryInterface
    private let uploadImageUseCase: UploadImageUseCase

    init(
        hobbyRepository: HobbyRepositoryInterface = HobbyRepository(),
        uploadImageUseCase: UploadImageUseCase = UploadImageUseCase()
    ) {
        self.hobbyRepository = hobbyRepository
        self.uploadImageUseCase = uploadImageUseCase
    }

    /// 갤러리에서 이미지 선택하여 취미 대표사진 변경
    /// - Parameters:
    ///   - hobbyId: 대표사진을 변경할 취미 ID
    ///   - image: 업로드할 이미지
    /// - Returns: 업데이트 결과 (message)
    func executeWithImage(hobbyId: Int, image: UIImage) async throws -> UpdateHobbyCoverResult {
        // 1. S3에 이미지 업로드
        let uploadedUrls = try await uploadImageUseCase.execute(
            images: [(image: image, usage: .coverImage)]
        )

        guard let coverImageUrl = uploadedUrls.first else {
            throw CoverImageError.uploadFailed
        }

        // 2. 취미 대표사진 URL 업데이트
        let result = try await hobbyRepository.updateCoverImage(
            hobbyId: hobbyId,
            coverImageUrl: coverImageUrl,
            recordId: nil
        )
        return result
    }

    /// 활동 기록에서 이미지 선택하여 취미 대표사진 변경
    /// - Parameter recordId: 선택한 활동 기록 ID
    /// - Returns: 업데이트 결과 (message)
    func executeWithRecord(recordId: Int) async throws -> UpdateHobbyCoverResult {
        let result = try await hobbyRepository.updateCoverImage(
            hobbyId: nil,
            coverImageUrl: nil,
            recordId: recordId
        )
        return result
    }
}

enum CoverImageError: Error {
    case uploadFailed
}
