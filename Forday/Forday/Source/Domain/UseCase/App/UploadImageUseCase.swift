//
//  UploadImageUseCase.swift
//  Forday
//
//  Created by Subeen on 1/21/26.
//

import Foundation
import UIKit

final class UploadImageUseCase {

    private let repository: AppRepositoryInterface

    init(repository: AppRepositoryInterface = AppRepository()) {
        self.repository = repository
    }

    /// 이미지 업로드 전체 플로우: Presigned URL 발급 → S3 업로드 → File URL 반환
    func execute(images: [(image: UIImage, usage: ImageUsage)]) async throws -> [String] {
        // 1. ImageInput 생성 (JPEG 압축)
        let imageInputs: [ImageInput] = images.enumerated().map { index, item in
            let filename = "image_\(UUID().uuidString).jpg"
            return ImageInput(
                originalFilename: filename,
                contentType: "image/jpeg",
                usage: item.usage,
                order: index + 1
            )
        }

        // 2. Presigned URL 발급
        let uploadInfos = try await repository.fetchPresignedUrl(images: imageInputs)

        // 3. S3에 각 이미지 업로드
        var fileUrls: [String] = []
        for (index, uploadInfo) in uploadInfos.enumerated() {
            guard let imageData = images[index].image.jpegData(compressionQuality: 0.8) else {
                throw ImageUploadError.imageCompressionFailed
            }

            try await uploadToS3(imageData: imageData, uploadUrl: uploadInfo.uploadUrl, contentType: "image/jpeg")
            fileUrls.append(uploadInfo.fileUrl)
        }

        return fileUrls
    }

    /// S3에 이미지 업로드 (Presigned URL 사용)
    private func uploadToS3(imageData: Data, uploadUrl: String, contentType: String) async throws {
        guard let url = URL(string: uploadUrl) else {
            throw ImageUploadError.invalidURL
        }

        var request = URLRequest(url: url)
        request.httpMethod = "PUT"
        request.setValue(contentType, forHTTPHeaderField: "Content-Type")
        request.httpBody = imageData

        let (_, response) = try await URLSession.shared.data(for: request)

        guard let httpResponse = response as? HTTPURLResponse,
              (200...299).contains(httpResponse.statusCode) else {
            throw ImageUploadError.s3UploadFailed
        }
    }
}

enum ImageUploadError: Error {
    case imageCompressionFailed
    case invalidURL
    case s3UploadFailed
}
