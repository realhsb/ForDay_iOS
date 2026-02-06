//
//  AppleLoginUseCase.swift
//  Forday
//
//  Created by Subeen on 2/4/26.
//


import Foundation

struct AppleLoginUseCase {

    private let appleAuthService: AppleAuthService
    private let authRepository: AuthRepositoryInterface
    private let tokenStorage: TokenStorage

    init(
        appleAuthService: AppleAuthService = AppleAuthService(),
        authRepository: AuthRepositoryInterface,
        tokenStorage: TokenStorage = TokenStorage.shared
    ) {
        self.appleAuthService = appleAuthService
        self.authRepository = authRepository
        self.tokenStorage = tokenStorage
    }

    // MARK: - Execute

    func execute() async throws -> AuthToken {
        // 1. Apple SDK로 authorization_code 받기
        let authorizationCode = try await appleAuthService.login()

        // 2. authorization_code를 서버에 보내서 우리 서버 토큰 받기
        let authToken = try await authRepository.loginWithApple(appleIdentityToken: authorizationCode)

        // 3. 받은 토큰을 KeyChain에 저장
        try tokenStorage.saveTokens(
            accessToken: authToken.accessToken,
            refreshToken: authToken.refreshToken
        )

        // 4. 게스트 ID 삭제 (이전에 게스트 로그인 했을 수 있으므로)
        try? tokenStorage.deleteGuestUserId()

        // 5. 전체 AuthToken 반환
        return authToken
    }
}
