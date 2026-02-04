//
//  SwitchToKakaoUseCase.swift
//  Forday
//
//  Created by Subeen on 2/4/26.
//

import Foundation

struct SwitchToKakaoUseCase {

    private let kakaoAuthService: SocialAuthService
    private let authRepository: AuthRepositoryInterface
    private let tokenStorage: TokenStorage

    init(
        kakaoAuthService: SocialAuthService = KakaoAuthService(),
        authRepository: AuthRepositoryInterface,
        tokenStorage: TokenStorage = TokenStorage.shared
    ) {
        self.kakaoAuthService = kakaoAuthService
        self.authRepository = authRepository
        self.tokenStorage = tokenStorage
    }

    // MARK: - Execute

    func execute() async throws -> AuthToken {
        // 1. 카카오 SDK로 카카오 토큰 받기
        let kakaoAccessToken = try await kakaoAuthService.login()

        // 2. 카카오 토큰을 서버에 보내서 계정 전환
        let authToken = try await authRepository.switchAccount(
            socialType: .kakao,
            socialCode: kakaoAccessToken
        )

        // 3. 새로운 토큰을 KeyChain에 저장
        try tokenStorage.saveTokens(
            accessToken: authToken.accessToken,
            refreshToken: authToken.refreshToken
        )

        // 4. 게스트 ID 삭제 (더 이상 게스트가 아님)
        try tokenStorage.deleteGuestUserId()

        // 5. 전체 AuthToken 반환
        return authToken
    }
}
