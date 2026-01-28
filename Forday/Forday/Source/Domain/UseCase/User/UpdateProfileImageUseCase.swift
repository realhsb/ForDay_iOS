//
//  UpdateProfileImageUseCase.swift
//  Forday
//
//  Created by Subeen on 1/27/26.
//

import Foundation
import UIKit

final class UpdateProfileImageUseCase {

    private let usersRepository: UsersRepositoryInterface
    private let uploadImageUseCase: UploadImageUseCase

    init(
        usersRepository: UsersRepositoryInterface = UsersRepository(),
        uploadImageUseCase: UploadImageUseCase = UploadImageUseCase()
    ) {
        self.usersRepository = usersRepository
        self.uploadImageUseCase = uploadImageUseCase
    }

    /// 프로필 이미지 업로드 및 변경
    /// - Parameter image: 업로드할 이미지
    /// - Returns: 업데이트 결과 (profileImageUrl, message)
    func execute(image: UIImage) async throws -> UpdateProfileImageResult {
        // 1. S3에 이미지 업로드
        let uploadedUrls = try await uploadImageUseCase.execute(
            images: [(image: image, usage: .profileImage)]
        )

        guard let profileImageUrl = uploadedUrls.first else {
            throw ProfileImageError.uploadFailed
        }

        // 2. 프로필 이미지 URL 업데이트
        let result = try await usersRepository.updateProfileImage(profileImageUrl: profileImageUrl)
        return result
    }
}

enum ProfileImageError: Error {
    case uploadFailed
}
