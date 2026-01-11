//
//  AuthRepository.swift
//  Forday
//
//  Created by Subeen on 1/9/26.
//


import Foundation

final class AuthRepository: AuthRepositoryInterface {
    
    private let apiService: AuthService
    
    init(apiService: AuthService = AuthService()) {
        self.apiService = apiService
    }
    
    // MARK: - Kakao Login
    
    func loginWithKakao(kakaoAccessToken: String) async throws -> AuthToken {
        let request = DTO.KakaoLoginRequest(kakaoAccessToken: kakaoAccessToken)
        let response = try await apiService.loginWithKakao(request: request)
        return response.data.toDomain()
    }
    
    // MARK: - Apple Login
    
    func loginWithApple(appleIdentityToken: String) async throws -> AuthToken {
        // TODO: 나중에 구현
        fatalError("Apple Login not implemented yet")
    }
    
    // MARK: - Guest Login
    
    func loginAsGuest(guestUserId: String?) async throws -> AuthToken {
        let request = DTO.GuestLoginRequest(guestUserId: guestUserId)
        let response = try await apiService.loginAsGuest(request: request)
        return response.data.toDomain()
    }
    
    // MARK: - Refresh Token
    
    func refreshToken(refreshToken: String) async throws -> AuthToken {
        // TODO: 나중에 구현
        fatalError("Refresh Token not implemented yet")
    }
    
    // MARK: - Logout
    
    func logout() async throws {
        // TODO: 나중에 구현
        fatalError("Logout not implemented yet")
    }
}
