//
//  GeneralSettingsViewController.swift
//  Forday
//
//  Created by Subeen on 2/7/26.
//

import UIKit

final class GeneralSettingsViewController: UIViewController {

    // MARK: - Properties

    private var settingsView: GeneralSettingsView {
        return view as! GeneralSettingsView
    }

    weak var coordinator: MainTabBarCoordinator?

    // MARK: - Lifecycle

    override func loadView() {
        view = GeneralSettingsView()
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        setupActions()
        setupAppVersion()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: animated)
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        navigationController?.setNavigationBarHidden(false, animated: animated)
    }
}

// MARK: - Setup

extension GeneralSettingsViewController {
    private func setupActions() {
        // Back button
        settingsView.backButton.addTarget(
            self,
            action: #selector(backButtonTapped),
            for: .touchUpInside
        )

        // Row tap gestures
        let termsGesture = UITapGestureRecognizer(target: self, action: #selector(termsOfServiceTapped))
        settingsView.termsOfServiceRow.addGestureRecognizer(termsGesture)

        let privacyGesture = UITapGestureRecognizer(target: self, action: #selector(privacyPolicyTapped))
        settingsView.privacyPolicyRow.addGestureRecognizer(privacyGesture)

        let logoutGesture = UITapGestureRecognizer(target: self, action: #selector(logoutTapped))
        settingsView.logoutRow.addGestureRecognizer(logoutGesture)
    }

    private func setupAppVersion() {
        if let version = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String {
            settingsView.updateAppVersion(version)
        }
    }
}

// MARK: - Actions

extension GeneralSettingsViewController {
    @objc private func backButtonTapped() {
        navigationController?.popViewController(animated: true)
    }

    @objc private func termsOfServiceTapped() {
        // TODO: Open terms of service URL
        print("📄 Terms of service tapped")
        showComingSoonAlert(feature: "서비스 이용약관")
    }

    @objc private func privacyPolicyTapped() {
        // TODO: Open privacy policy URL
        print("🔒 Privacy policy tapped")
        showComingSoonAlert(feature: "개인정보 보호정책")
    }

    @objc private func logoutTapped() {
        showLogoutAlert()
    }

    private func showLogoutAlert() {
        let alert = UIAlertController(
            title: "로그아웃",
            message: "정말 로그아웃 하시겠습니까?",
            preferredStyle: .alert
        )

        alert.addAction(UIAlertAction(title: "취소", style: .cancel))
        alert.addAction(UIAlertAction(title: "로그아웃", style: .destructive) { [weak self] _ in
            self?.performLogout()
        })

        present(alert, animated: true)
    }

    private func performLogout() {
        do {
            // Delete tokens
            try TokenStorage.shared.deleteAllTokens()

            // Delete onboarding data (optional)
            try? OnboardingDataStorage.shared.delete()

            print("✅ Logout successful")

            // Notify AppCoordinator
            coordinator?.parentCoordinator?.logout()

        } catch {
            print("❌ Logout failed: \(error)")
            showError(error.localizedDescription)
        }
    }

    private func showComingSoonAlert(feature: String) {
        let alert = UIAlertController(
            title: "준비 중",
            message: "\(feature) 기능은 곧 제공될 예정입니다.",
            preferredStyle: .alert
        )
        alert.addAction(UIAlertAction(title: "확인", style: .default))
        present(alert, animated: true)
    }

    private func showError(_ message: String) {
        let alert = UIAlertController(
            title: "오류",
            message: message,
            preferredStyle: .alert
        )
        alert.addAction(UIAlertAction(title: "확인", style: .default))
        present(alert, animated: true)
    }
}

#if DEBUG
#Preview {
    GeneralSettingsViewController()
}
#endif
