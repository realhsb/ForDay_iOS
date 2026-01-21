//
//  PresignedUrlRequest.swift
//  Forday
//
//  Created by Subeen on 1/21/26.
//

import Foundation

extension DTO {
    struct PresignedUrlRequest: BaseRequest {
        let images: [ImageUploadInput]
    }

    struct ImageUploadInput: Codable {
        let originalFilename: String
        let contentType: String
        let usage: String
        let order: Int
    }
}
