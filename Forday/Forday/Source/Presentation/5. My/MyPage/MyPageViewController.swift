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

    private var myPageView: ProfileView {
        return view as! ProfileView
    }

    private let viewModel: MyPageViewModel
    private var cancellables = Set<AnyCancellable>()

    // Coordinator
    weak var coordinator: MainTabBarCoordinator?

    // Child ViewControllers for tab content
    private var activityGridVC: ActivityGridViewController?
    private var hobbyCardStackVC: HobbyCardStackViewController?
    private var scrapGridVC: ScrapGridViewController?

    // Settings dropdown
    private var settingsDropdownBackgroundView: UIView?
    private var settingsDropdownView: DropdownMenuView<MySettingsMenuItem>?

    // Guest login bottom sheet
    private var hasShownGuestLoginSheet = false

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
        view = ProfileView()
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        setupNavigationBar()
        setupSegmentedControl()
        bind()
        setupEventBus()
        loadData()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        checkGuestAccess()
    }

    // MARK: - Guest Access Check

    private func checkGuestAccess() {
        // 이미 바텀시트를 보여줬으면 다시 표시하지 않음
        guard !hasShownGuestLoginSheet else { return }

        // 게스트 유저인 경우 로그인 바텀시트 표시
        if TokenStorage.shared.loadGuestUserId() != nil {
            hasShownGuestLoginSheet = true
            GuestLoginBottomSheetViewController.present(from: self, delegate: self)
        }
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

        // Listen to hobby creation
        AppEventBus.shared.hobbyCreated
            .sink { [weak self] hobbyId in
                Task {
                    // Refresh both hobbies and activities
                    await self?.viewModel.refreshHobbies()
                    await self?.viewModel.refreshActivities()
                }
            }
            .store(in: &cancellables)

        // Listen to hobby settings updates
        AppEventBus.shared.hobbySettingsUpdated
            .sink { [weak self] hobbyId in
                Task {
                    await self?.viewModel.refreshHobbies()
                }
            }
            .store(in: &cancellables)

        // Listen to hobby deletion
        AppEventBus.shared.hobbyDeleted
            .sink { [weak self] in
                Task {
                    // Refresh both hobbies and activities
                    await self?.viewModel.refreshHobbies()
                    await self?.viewModel.refreshActivities()
                }
            }
            .store(in: &cancellables)

        // Listen to activity record creation
        AppEventBus.shared.activityRecordCreated
            .sink { [weak self] hobbyId in
                Task {
                    await self?.viewModel.refreshActivities()
                }
            }
            .store(in: &cancellables)

        // Listen to activity record deletion
        AppEventBus.shared.activityRecordDeleted
            .sink { [weak self] in
                Task {
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

        // Scrap Grid ViewController
        let scrapGridVC = ScrapGridViewController(viewModel: viewModel)
        scrapGridVC.coordinator = coordinator
        addChild(scrapGridVC)
        self.scrapGridVC = scrapGridVC
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
                    $0.leading.trailing.equalToSuperview()
                    $0.top.equalToSuperview().offset(20)
                    $0.bottom.equalToSuperview().offset(24)
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

        case .scraps:
            if let scrapGridVC = scrapGridVC {
                scrapGridVC.view.frame = myPageView.contentContainerView.bounds
                myPageView.contentContainerView.addSubview(scrapGridVC.view)
                scrapGridVC.view.snp.makeConstraints {
                    $0.edges.equalToSuperview()
                }
                scrapGridVC.didMove(toParent: self)

                // Load scraps when first switched to scraps tab
                if viewModel.scraps.isEmpty {
                    Task {
                        await viewModel.refreshScraps()
                    }
                }
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
        let dropdownView = DropdownMenuView(items: MySettingsMenuItem.allCases)
        dropdownView.onItemSelected = { [weak self] menuItem in
            self?.handleSettingsMenuSelection(menuItem)
        }

        // Show dropdown
        guard let navigationBar = navigationController?.navigationBar else { return }
        dropdownView.showInParent(view, belowNavigationBar: navigationBar)

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

    private func handleSettingsMenuSelection(_ menuItem: MySettingsMenuItem) {
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

// MARK: - GuestLoginBottomSheetDelegate

extension MyPageViewController: GuestLoginBottomSheetDelegate {
    func guestLoginBottomSheetDidLoginSuccess(_ controller: GuestLoginBottomSheetViewController, authToken: AuthToken) {
        // 로그인 성공 후 데이터 새로고침
        Task {
            await viewModel.fetchInitialData()
        }

        // 토스트 메시지 표시
        ToastView.show(message: "로그인되었습니다")
    }

    func guestLoginBottomSheetDidDismiss(_ controller: GuestLoginBottomSheetViewController) {
        // 바텀시트가 로그인 없이 닫힌 경우 홈 탭으로 이동
        coordinator?.switchToHomeTab()
    }
}

#Preview {
    MyPageViewController()
}
