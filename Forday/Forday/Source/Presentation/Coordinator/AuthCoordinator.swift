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
    func handleLoginSuccess(isNewUser: Bool) {
        if isNewUser {
            // 신규 유저 → 온보딩
            showOnboarding()
        } else {
            // 기존 유저 → 홈
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
}
