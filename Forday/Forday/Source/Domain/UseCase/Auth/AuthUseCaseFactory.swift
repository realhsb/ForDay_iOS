//
//  AuthUseCaseFactory.swift
//  Forday
//
//  Created by Subeen on 1/12/26.
//


// Domain/UseCase/Auth/AuthUseCaseFactory.swift
struct AuthUseCaseFactory {
    
    private let authRepository: AuthRepositoryInterface
    private let kakaoAuthService: SocialAuthService
    private let tokenStorage: TokenStorage
    
    init(
        authRepository: AuthRepositoryInterface = AuthRepository(),
        kakaoAuthService: SocialAuthService = KakaoAuthService(),
        tokenStorage: TokenStorage = TokenStorage.shared
    ) {
        self.authRepository = authRepository
        self.kakaoAuthService = kakaoAuthService
        self.tokenStorage = tokenStorage
    }
    
    func makeKakaoLoginUseCase() -> KakaoLoginUseCase {
        return KakaoLoginUseCase(
            kakaoAuthService: kakaoAuthService,
            authRepository: authRepository,
            tokenStorage: tokenStorage
        )
    }
    
    func makeGuestLoginUseCase() -> GuestLoginUseCase {
        return GuestLoginUseCase(
            authRepository: authRepository,
            tokenStorage: tokenStorage
        )
    }
    
//    func makeAppleLoginUseCase() -> AppleLoginUseCase {
//        return AppleLoginUseCase(
//            // TODO: Apple 구현 시 추가
//            authRepository: authRepository,
//            tokenStorage: tokenStorage
//        )
//    }
}
