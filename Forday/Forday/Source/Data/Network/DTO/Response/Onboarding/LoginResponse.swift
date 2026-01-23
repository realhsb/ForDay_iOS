//
//  LoginResponse.swift
//  Forday
//
//  Created by Subeen on 1/9/26.
//

extension DTO {

    struct LoginResponse: BaseResponse {
        let status: Int
        let success: Bool
        let data: LoginData
    }

    struct LoginData: Codable {
        let accessToken: String
        let refreshToken: String
        let newUser: Bool
        let socialType: String
        let guestUserId: String?
    }
}

extension DTO.LoginData {
    func toDomain() -> AuthToken {
        return AuthToken(
            accessToken: accessToken,
            refreshToken: refreshToken,
            isNewUser: newUser,
            socialType: SocialType(rawValue: socialType) ?? .guest,
            guestUserId: guestUserId
        )
    }
}
