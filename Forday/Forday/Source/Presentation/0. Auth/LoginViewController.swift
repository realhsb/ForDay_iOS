//
//  LoginViewController.swift
//  Forday
//
//  Created by Subeen on 1/11/26.
//


import UIKit
import Combine

class LoginViewController: UIViewController {
    
    // MARK: - Properties
    
    private let loginView = LoginView()
    private var cancellables = Set<AnyCancellable>()
    
    // UseCase
    private let kakaoLoginUseCase: KakaoLoginUseCase
    private let appleLoginUseCase: AppleLoginUseCase
    private let guestLoginUseCase: GuestLoginUseCase
    
    // Coordinator
    weak var coordinator: AuthCoordinator?
    
    // MARK: - Initialization
    
    init(useCaseFactory: AuthUseCaseFactory = AuthUseCaseFactory()) {
        self.kakaoLoginUseCase = useCaseFactory.makeKakaoLoginUseCase()
        self.appleLoginUseCase = useCaseFactory.makeAppleLoginUseCase()
        self.guestLoginUseCase = useCaseFactory.makeGuestLoginUseCase()
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Lifecycle
    
    override func loadView() {
        view = loginView
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupActions()
    }
}

// MARK: - Setup

extension LoginViewController {
    private func setupActions() {
        loginView.kakaoLoginButton.addTarget(
            self,
            action: #selector(kakaoLoginButtonTapped),
            for: .touchUpInside
        )
        
        loginView.appleLoginButton.addTarget(
            self,
            action: #selector(appleLoginButtonTapped),
            for: .touchUpInside
        )
        
        loginView.guestLoginButton.addTarget(
            self,
            action: #selector(guestLoginButtonTapped),
            for: .touchUpInside
        )
    }
    
    // MARK: - Actions
    
    @objc private func kakaoLoginButtonTapped() {
        Task {
            do {
                let authToken = try await kakaoLoginUseCase.execute()
                await MainActor.run {
                    coordinator?.handleLoginSuccess(authToken: authToken)
                }
            } catch {
                // 사용자 취소 시 에러 알림 표시하지 않음
                if isUserCancellationError(error) { return }
                await MainActor.run {
                    showError(error)
                }
            }
        }
    }

    @objc private func appleLoginButtonTapped() {
        Task {
            do {
                let authToken = try await appleLoginUseCase.execute()
                await MainActor.run {
                    coordinator?.handleLoginSuccess(authToken: authToken)
                }
            } catch {
                // 사용자 취소 시 에러 알림 표시하지 않음
                if isUserCancellationError(error) { return }
                await MainActor.run {
                    showError(error)
                }
            }
        }
    }
    
    @objc private func guestLoginButtonTapped() {
        print("🟡 게스트 로그인 버튼 클릭됨")
        Task {
            do {
                let authToken = try await guestLoginUseCase.execute()
                await MainActor.run {
                    print("🟡 게스트 로그인 성공 → handleLoginSuccess 호출")
                    coordinator?.handleLoginSuccess(authToken: authToken)
                }
            } catch {
                await MainActor.run {
                    print("🟡 게스트 로그인 실패: \(error)")
                    showError(error)
                }
            }
        }
    }
    
    // MARK: - Helper

    private func isUserCancellationError(_ error: Error) -> Bool {
        // Apple 로그인 취소
        if let appleError = error as? AppleAuthService.AppleAuthError,
           case .userCancelled = appleError {
            return true
        }
        // Kakao 로그인 취소
        if let kakaoError = error as? KakaoAuthService.KakaoAuthError,
           case .userCancelled = kakaoError {
            return true
        }
        return false
    }

    private func showError(_ error: Error) {
        let alert = UIAlertController(
            title: "로그인 실패",
            message: error.localizedDescription,
            preferredStyle: .alert
        )
        alert.addAction(UIAlertAction(title: "확인", style: .default))
        present(alert, animated: true)
    }
}

#Preview {
    LoginViewController()
}
