//
//  UsersHobbiesInProgressResponse.swift
//  Forday
//
//  Created by Subeen on 1/26/26.
//

extension DTO {
    struct UsersHobbiesInProgressResponse: BaseResponse {
        let status: Int
        let success: Bool
        let data: UsersHobbiesInProgressData

        struct UsersHobbiesInProgressData: Codable {
            let inProgressHobbyCount: Int
            let hobbyCardCount: Int
            let hobbyList: [HobbyData]
        }

        struct HobbyData: Codable {
            let hobbyId: Int
            let hobbyName: String
            let thumbnailImageUrl: String
            let status: String
        }
    }
}

// MARK: - Domain Mapping

extension DTO.UsersHobbiesInProgressResponse {
    func toDomain() -> MyHobbiesResult {
        MyHobbiesResult(
            inProgressHobbyCount: data.inProgressHobbyCount,
            hobbyCardCount: data.hobbyCardCount,
            hobbies: data.hobbyList.map { $0.toDomain() }
        )
    }
}

extension DTO.UsersHobbiesInProgressResponse.HobbyData {
    func toDomain() -> MyPageHobby {
        MyPageHobby(
            hobbyId: hobbyId,
            hobbyName: hobbyName,
            thumbnailImageUrl: thumbnailImageUrl,
            status: HobbyStatus(rawValue: status) ?? .inProgress
        )
    }
}
