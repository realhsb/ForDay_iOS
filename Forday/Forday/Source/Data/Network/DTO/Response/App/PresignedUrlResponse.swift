//
//  PresignedUrlResponse.swift
//  Forday
//
//  Created by Subeen on 1/21/26.
//

import Foundation

extension DTO {
    struct PresignedUrlResponse: BaseResponse {
        let status: Int
        let success: Bool
        let data: PresignedUrlData
    }

    struct PresignedUrlData: Codable {
        let images: [PresignedUrlInfo]
    }

    struct PresignedUrlInfo: Codable {
        let uploadUrl: String
        let fileUrl: String
        let order: Int
    }
}

extension DTO.PresignedUrlResponse {
    func toDomain() -> [ImageUploadInfo] {
        return data.images.map { info in
            ImageUploadInfo(
                uploadUrl: info.uploadUrl,
                fileUrl: info.fileUrl,
                order: info.order
            )
        }
    }
}
