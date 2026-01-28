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
    private let guestLoginUseCase: GuestLoginUseCase
    
    // Coordinator
    weak var coordinator: AuthCoordinator?
    
    // MARK: - Initialization
    
    init(useCaseFactory: AuthUseCaseFactory = AuthUseCaseFactory()) {
        self.kakaoLoginUseCase = useCaseFactory.makeKakaoLoginUseCase()
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
                await MainActor.run {
                    showError(error)
                }
            }
        }
    }
    
    @objc private func appleLoginButtonTapped() {
        print("애플 로그인")
        // TODO: 애플 로그인 처리
    }
    
    @objc private func guestLoginButtonTapped() {
        Task {
            do {
                let authToken = try await guestLoginUseCase.execute()
                await MainActor.run {
                    coordinator?.handleLoginSuccess(authToken: authToken)
                }
            } catch {
                await MainActor.run {
                    showError(error)
                }
            }
        }
    }
    
    // MARK: - Helper
    
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
