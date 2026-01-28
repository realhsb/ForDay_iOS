//
//  AuthCoordinator.swift
//  Forday
//
//  Created by Subeen on 1/11/26.
//


import UIKit

class AuthCoordinator: Coordinator {
    
    let navigationController: UINavigationController
    weak var parentCoordinator: AppCoordinator?
    
    private var onboardingCoordinator: OnboardingCoordinator?
    
    init(navigationController: UINavigationController) {
        self.navigationController = navigationController
    }
    
    func start() {
        showLogin()
    }
    
    // 로그인 화면
    func showLogin() {
        let vc = LoginViewController()
        vc.coordinator = self
        navigationController.setViewControllers([vc], animated: false)
    }
    
    // 로그인 성공 후 분기 처리
    func handleLoginSuccess(authToken: AuthToken) {
        print("🔵 handleLoginSuccess 호출됨")
        print("   - nicknameSet: \(authToken.nicknameSet)")
        print("   - onboardingCompleted: \(authToken.onboardingCompleted)")
        print("   - socialType: \(authToken.socialType)")
        print("   - guestUserId: \(authToken.guestUserId ?? "nil")")
        print("   - onboardingData: \(authToken.onboardingData != nil ? "있음" : "없음")")

        // 닉네임이 설정되지 않았으면 무조건 닉네임 설정 화면으로
        if !authToken.nicknameSet {
            // 케이스 2: 취미 생성 완료 + 닉네임 미설정 → 닉네임 설정 화면
            if authToken.onboardingCompleted {
                print("   ➡️ 닉네임 설정 화면으로 이동")
                showNicknameSetup()
            }
            // 케이스 3: 취미 생성 안 함 → 온보딩 시작
            else {
                print("   ➡️ 온보딩 시작 화면으로 이동")
                showOnboarding()
            }
        }
        // 케이스 1: 닉네임 설정 완료 → 홈
        else {
            print("   ➡️ 홈으로 이동")
            showHome()
        }
    }
    
    // 온보딩 시작
    func showOnboarding() {
        let onboardingNav = UINavigationController()

        onboardingNav.modalPresentationStyle = .fullScreen

        let onboardingCoordinator = OnboardingCoordinator(navigationController: onboardingNav)
        onboardingCoordinator.parentCoordinator = self
        onboardingCoordinator.start()

        self.onboardingCoordinator = onboardingCoordinator
        navigationController.present(onboardingNav, animated: true)
    }

    // 닉네임 설정 화면 (재로그인 시)
    func showNicknameSetup() {
        let onboardingNav = UINavigationController()

        onboardingNav.modalPresentationStyle = .fullScreen

        let onboardingCoordinator = OnboardingCoordinator(navigationController: onboardingNav)
        onboardingCoordinator.parentCoordinator = self
        onboardingCoordinator.showNicknameSetup()

        self.onboardingCoordinator = onboardingCoordinator
        navigationController.present(onboardingNav, animated: true)
    }
    
    // 온보딩 완료 후 홈으로
    func completeOnboarding() {
        print("🟢 completeOnboarding 호출됨")
        
        // 온보딩 코디네이터 참조 정리
        onboardingCoordinator = nil
        
        // ✅ dismiss 없이 바로 홈으로!
        parentCoordinator?.showMainTabBar()
    }
    
    // 홈 화면
    func showHome() {
        parentCoordinator?.showMainTabBar()
    }

    // 자동 로그인 (앱 시작 시, 토큰 valid할 때)
    func autoLogin() {
        print("🔵 autoLogin() 시작")
        Task {
            do {
                // 1. guestUserId가 있는지 확인
                let tokenStorage = TokenStorage.shared
                let savedGuestUserId = tokenStorage.loadGuestUserId()
                print("   - 저장된 guestUserId: \(savedGuestUserId ?? "없음")")

                if let guestUserId = savedGuestUserId {
                    print("🔄 게스트 사용자 자동 재로그인 시도: \(guestUserId)")

                    // 게스트 재로그인
                    let guestLoginUseCase = GuestLoginUseCase(
                        authRepository: AuthRepository()
                    )
                    let authToken = try await guestLoginUseCase.execute()

                    // 로그인 성공 처리
                    await MainActor.run {
                        handleLoginSuccess(authToken: authToken)
                    }
                    return
                }

                print("   - guestUserId 없음 → 일반 사용자로 처리")
                // 2. 일반 사용자 (카카오/애플) - 사용자 정보 조회로 닉네임 설정 여부 확인
                let usersService = UsersService()
                let userInfo = try await usersService.fetchUserInfo()

                await MainActor.run {
                    // nickname이 비어있으면 닉네임 설정 화면으로
                    if userInfo.data.nickname.isEmpty {
                        print("   ➡️ 닉네임 설정 화면으로 이동")
                        showNicknameSetup()
                    } else {
                        // nickname이 있으면 홈으로
                        print("   ➡️ 홈으로 이동")
                        showHome()
                    }
                }

            } catch {
                // 자동 로그인 실패 - 로그인 화면으로
                await MainActor.run {
                    print("⚠️ 자동 로그인 실패: \(error)")
                    print("   ➡️ 로그인 화면으로 이동")
                    showLogin()
                }
            }
        }
    }
}
