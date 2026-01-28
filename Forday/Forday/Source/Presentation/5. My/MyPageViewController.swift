//
//  MyPageViewController.swift
//  Forday
//
//  Created by Subeen on 1/15/26.
//

import UIKit
import SnapKit
import Then
import Combine

final class MyPageViewController: UIViewController {

    // MARK: - Properties

    private var myPageView: MyPageView {
        return view as! MyPageView
    }

    private let viewModel: MyPageViewModel
    private var cancellables = Set<AnyCancellable>()

    // Coordinator
    weak var coordinator: MainTabBarCoordinator?

    // Child ViewControllers for tab content
    private var activityGridVC: ActivityGridViewController?
    private var hobbyCardStackVC: HobbyCardStackViewController?

    // Settings dropdown
    private var settingsDropdownBackgroundView: UIView?
    private var settingsDropdownView: SettingsDropdownView?

    // MARK: - Initialization

    init(viewModel: MyPageViewModel = MyPageViewModel()) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Lifecycle

    override func loadView() {
        view = MyPageView()
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        setupNavigationBar()
        setupSegmentedControl()
        bind()
        setupEventBus()
        loadData()
    }
}

// MARK: - Setup

extension MyPageViewController {
    private func setupNavigationBar() {
        title = "마이페이지"

        // Settings button
        let settingsButton = UIBarButtonItem(
            image: UIImage(systemName: "gearshape"),
            style: .plain,
            target: self,
            action: #selector(settingsButtonTapped)
        )
        settingsButton.tintColor = .label

        // Notification button
        let notificationButton = UIBarButtonItem(
            image: UIImage(systemName: "bell"),
            style: .plain,
            target: self,
            action: #selector(notificationButtonTapped)
        )
        notificationButton.tintColor = .label

        navigationItem.rightBarButtonItems = [settingsButton, notificationButton]
    }

    private func setupSegmentedControl() {
        myPageView.segmentedControlView.onSegmentChanged = { [weak self] tab in
            self?.viewModel.switchTab(to: tab)
        }
    }

    private func setupEventBus() {
        // Listen to profile updates
        AppEventBus.shared.profileDidUpdate
            .sink { [weak self] in
                Task {
                    await self?.viewModel.refreshUserProfile()
                }
            }
            .store(in: &cancellables)

        // Listen to hobbies updates
        AppEventBus.shared.hobbiesDidUpdate
            .sink { [weak self] in
                Task {
                    await self?.viewModel.refreshHobbies()
                }
            }
            .store(in: &cancellables)

        // Listen to hobby deletion
        AppEventBus.shared.hobbyDeleted
            .sink { [weak self] in
                print("🗑️ 취미 삭제됨! MyPage 새로고침")
                Task {
                    // Refresh both hobbies and activities
                    await self?.viewModel.refreshHobbies()
                    await self?.viewModel.refreshActivities()
                }
            }
            .store(in: &cancellables)
    }

    private func bind() {
        // User profile
        viewModel.$userProfile
            .receive(on: DispatchQueue.main)
            .sink { [weak self] profile in
                guard let profile = profile else { return }
                self?.myPageView.headerView.configure(with: profile)
            }
            .store(in: &cancellables)

        // Current tab
        viewModel.$currentTab
            .receive(on: DispatchQueue.main)
            .sink { [weak self] tab in
                self?.switchToTab(tab)
            }
            .store(in: &cancellables)

        // Hobbies count for segmented control
        viewModel.$myHobbies
            .receive(on: DispatchQueue.main)
            .sink { [weak self] hobbies in
                let inProgressCount = hobbies.filter { $0.status == .inProgress }.count
                self?.myPageView.segmentedControlView.updateCounts(
                    inProgressCount: inProgressCount,
                    hobbyCardsCount: 0 // Will be updated when hobby cards are implemented
                )
            }
            .store(in: &cancellables)

        // Hobby cards count
        viewModel.$hobbyCards
            .receive(on: DispatchQueue.main)
            .sink { [weak self] cards in
                guard let hobbies = self?.viewModel.myHobbies else { return }
                let inProgressCount = hobbies.filter { $0.status == .inProgress }.count
                self?.myPageView.segmentedControlView.updateCounts(
                    inProgressCount: inProgressCount,
                    hobbyCardsCount: cards.count
                )
            }
            .store(in: &cancellables)

        // Loading state
        viewModel.$isLoading
            .receive(on: DispatchQueue.main)
            .sink { [weak self] isLoading in
                if isLoading {
                    print("🔄 Loading MyPage data...")
                } else {
                    print("✅ MyPage data loaded")
                }
            }
            .store(in: &cancellables)

        // Error handling
        viewModel.$error
            .receive(on: DispatchQueue.main)
            .compactMap { $0 }
            .sink { [weak self] error in
                print("❌ Error: \(error)")
                self?.handleError(error)
            }
            .store(in: &cancellables)
    }

    private func loadData() {
        Task {
            await viewModel.fetchInitialData()

            // After data is loaded, setup child view controllers
            await MainActor.run {
                setupChildViewControllers()
                switchToTab(.activities)
            }
        }
    }

    private func setupChildViewControllers() {
        // Activity Grid ViewController
        let activityGridVC = ActivityGridViewController(viewModel: viewModel)
        activityGridVC.coordinator = coordinator
        addChild(activityGridVC)
        self.activityGridVC = activityGridVC

        // Hobby Card Stack ViewController
        let hobbyCardStackVC = HobbyCardStackViewController(viewModel: viewModel)
        addChild(hobbyCardStackVC)
        self.hobbyCardStackVC = hobbyCardStackVC
    }

    private func switchToTab(_ tab: MyPageTab) {
        // Remove current child view
        myPageView.contentContainerView.subviews.forEach { $0.removeFromSuperview() }

        switch tab {
        case .activities:
            if let activityGridVC = activityGridVC {
                activityGridVC.view.frame = myPageView.contentContainerView.bounds
                myPageView.contentContainerView.addSubview(activityGridVC.view)
                activityGridVC.view.snp.makeConstraints {
                    $0.edges.equalToSuperview()
                }
                activityGridVC.didMove(toParent: self)
            }

        case .hobbyCards:
            if let hobbyCardStackVC = hobbyCardStackVC {
                hobbyCardStackVC.view.frame = myPageView.contentContainerView.bounds
                myPageView.contentContainerView.addSubview(hobbyCardStackVC.view)
                hobbyCardStackVC.view.snp.makeConstraints {
                    $0.edges.equalToSuperview()
                }
                hobbyCardStackVC.didMove(toParent: self)
            }
        }
    }
}

// MARK: - Actions

extension MyPageViewController {
    @objc private func settingsButtonTapped() {
        // TODO: Show settings dropdown
        print("⚙️ Settings button tapped")
        showSettingsDropdown()
    }

    @objc private func notificationButtonTapped() {
        // TODO: Show notifications
        print("🔔 Notification button tapped")
    }

    private func showSettingsDropdown() {
        dismissSettingsDropdown() // Dismiss if already showing

        // Create transparent background
        let backgroundView = UIView()
        backgroundView.backgroundColor = .clear
        view.addSubview(backgroundView)

        backgroundView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }

        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(dismissSettingsDropdown))
        backgroundView.addGestureRecognizer(tapGesture)

        // Create dropdown
        let dropdownView = SettingsDropdownView()
        dropdownView.onMenuSelected = { [weak self] menuItem in
            self?.handleSettingsMenuSelection(menuItem)
        }

        // Show dropdown
        guard let navigationBar = navigationController?.navigationBar else { return }
        dropdownView.show(in: view, below: navigationItem.rightBarButtonItem!, navigationBar: navigationBar)

        // Store references
        settingsDropdownBackgroundView = backgroundView
        settingsDropdownView = dropdownView
    }

    @objc private func dismissSettingsDropdown() {
        settingsDropdownView?.dismiss()
        settingsDropdownBackgroundView?.removeFromSuperview()
        settingsDropdownView = nil
        settingsDropdownBackgroundView = nil
    }

    private func handleSettingsMenuSelection(_ menuItem: SettingsMenuItem) {
        dismissSettingsDropdown()

        switch menuItem {
        case .profileSettings:
            print("👤 Profile settings")
            showProfileEdit()

        case .hobbyPhotoManagement:
            print("🖼️ Hobby photo management")
            showHobbyCoverManagement()

        case .generalSettings:
            print("⚙️ General settings")
            showComingSoonAlert(feature: "전체설정")

        case .logout:
            print("🚪 Logout")
            showLogoutAlert()
        }
    }

    private func showProfileEdit() {
        coordinator?.showProfileEdit(currentProfile: viewModel.userProfile)
    }

    private func showHobbyCoverManagement() {
        let viewModel = ManageHobbyCoverViewModel()
        let vc = ManageHobbyCoverViewController(viewModel: viewModel)

        // Pass all hobbies to the viewModel (진행 중 + 보관)
        viewModel.setHobbies(self.viewModel.myHobbies)

        navigationController?.pushViewController(vc, animated: true)
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

    private func handleError(_ error: AppError) {
        let title: String
        let message = error.userMessage
        var actions: [UIAlertAction] = []

        switch error {
        case .network:
            title = "네트워크 오류"
            actions.append(UIAlertAction(title: "다시 시도", style: .default) { [weak self] _ in
                self?.loadData()
            })
            actions.append(UIAlertAction(title: "취소", style: .cancel))

        case .server:
            title = "오류"
            actions.append(UIAlertAction(title: "확인", style: .default))

        case .decoding, .unknown:
            title = "오류"
            actions.append(UIAlertAction(title: "확인", style: .default))
        }

        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        actions.forEach { alert.addAction($0) }
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

#Preview {
    MyPageViewController()
}
