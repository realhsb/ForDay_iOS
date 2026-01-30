//
//  GuestLoginUseCase.swift
//  Forday
//
//  Created by Subeen on 1/11/26.
//


import Foundation

struct GuestLoginUseCase {
    
    private let authRepository: AuthRepositoryInterface
    private let tokenStorage: TokenStorage
    
    init(
        authRepository: AuthRepositoryInterface,
        tokenStorage: TokenStorage = TokenStorage.shared
    ) {
        self.authRepository = authRepository
        self.tokenStorage = tokenStorage
    }
    
    // MARK: - Execute

    func execute() async throws -> AuthToken {
        // 1. 저장된 guestUserId 조회
        let savedGuestUserId = tokenStorage.loadGuestUserId()
        print("🟢 GuestLoginUseCase - savedGuestUserId: \(savedGuestUserId ?? "nil")")

        // 2. guestUserId로 게스트 로그인 (없으면 nil 전송)
        let authToken = try await authRepository.loginAsGuest(guestUserId: savedGuestUserId)
        print("🟢 GuestLoginUseCase - API 응답 받음")
        print("   - nicknameSet: \(authToken.nicknameSet)")
        print("   - onboardingCompleted: \(authToken.onboardingCompleted)")
        print("   - guestUserId: \(authToken.guestUserId ?? "nil")")

        // 3. 받은 토큰들 저장
        try tokenStorage.saveTokens(
            accessToken: authToken.accessToken,
            refreshToken: authToken.refreshToken
        )

        // 4. guestUserId 저장 (처음 로그인이면 새로 받은 값 저장)
        if let guestUserId = authToken.guestUserId {
            try tokenStorage.saveGuestUserId(guestUserId)
            print("🟢 GuestLoginUseCase - guestUserId 저장됨: \(guestUserId)")
        }

        // 5. 전체 AuthToken 반환
        return authToken
    }
}