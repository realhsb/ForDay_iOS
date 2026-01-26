//
//  UsersProfileImageUploadResponse.swift
//  Forday
//
//  Created by Subeen on 1/26/26.
//

extension DTO {
    struct UsersProfileImageUploadResponse: BaseResponse {
        let status: Int
        let success: Bool
        let data: UsersProfileImageUploadData
        
        struct UsersProfileImageUploadData: Codable {
            let profileImageUrl: String
            let message: String
        }
    }
}
