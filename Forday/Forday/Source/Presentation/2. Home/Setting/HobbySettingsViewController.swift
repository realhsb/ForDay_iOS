//
//  HobbySettingsViewController.swift
//  Forday
//
//  Created by Subeen on 1/22/26.
//

import UIKit
import Combine

class HobbySettingsViewController: UIViewController {

    // MARK: - Properties

    private let hobbySettingsView = HobbySettingsView()
    private let viewModel: HobbySettingsViewModel
    private var cancellables = Set<AnyCancellable>()
    weak var coordinator: MainTabBarCoordinator?

    // OnboardingCoordinator를 강하게 참조하여 메모리에서 해제되지 않도록 함
    private var onboardingCoordinator: OnboardingCoordinator?

    // MARK: - Initialization

    init(viewModel: HobbySettingsViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Lifecycle

    override func loadView() {
        view = hobbySettingsView
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        setupNavigationBar()
        setupTableView()
        setupSegmentedControl()
        bind()
        fetchInitialData()
    }

    // MARK: - Setup

    private func setupNavigationBar() {
        navigationItem.title = "내 취미 관리"
        navigationController?.navigationBar.prefersLargeTitles = false

        // Apply background color to navigation bar
        let appearance = UINavigationBarAppearance()
        appearance.configureWithOpaqueBackground()
        appearance.backgroundColor = .neutral50
        appearance.shadowColor = .clear
        navigationController?.navigationBar.standardAppearance = appearance
        navigationController?.navigationBar.scrollEdgeAppearance = appearance

        // Add chevron-left dismiss button
        let backButton = UIBarButtonItem(
            image: UIImage(systemName: "chevron.left"),
            style: .plain,
            target: self,
            action: #selector(dismissViewController)
        )
        backButton.tintColor = .label
        navigationItem.leftBarButtonItem = backButton
    }

    @objc private func dismissViewController() {
        dismiss(animated: true)
    }

    private func setupTableView() {
        hobbySettingsView.tableView.dataSource = self
        hobbySettingsView.tableView.delegate = self
    }

    private func setupSegmentedControl() {
        hobbySettingsView.segmentedControl.addTarget(self, action: #selector(segmentChanged(_:)), for: .valueChanged)
    }

    private func bind() {
        // Bind hobbies changes to reload table view
        viewModel.$hobbies
            .receive(on: DispatchQueue.main)
            .sink { [weak self] _ in
                self?.hobbySettingsView.reloadTableView()
            }
            .store(in: &cancellables)

        // Bind showAddHobbyCell changes to reload table view
        viewModel.$showAddHobbyCell
            .receive(on: DispatchQueue.main)
            .sink { [weak self] _ in
                self?.hobbySettingsView.reloadTableView()
            }
            .store(in: &cancellables)

        // Bind counts to update segmented control
        Publishers.CombineLatest3(viewModel.$inProgressCount, viewModel.$archivedCount, viewModel.$currentStatus)
            .receive(on: DispatchQueue.main)
            .sink { [weak self] inProgressCount, archivedCount, currentStatus in
                let selectedIndex = currentStatus == .inProgress ? 0 : 1
                self?.hobbySettingsView.updateSegmentedControl(
                    inProgressCount: inProgressCount,
                    archivedCount: archivedCount,
                    selectedIndex: selectedIndex
                )
            }
            .store(in: &cancellables)

        // Bind error messages
        viewModel.$errorMessage
            .receive(on: DispatchQueue.main)
            .compactMap { $0 }
            .sink { [weak self] errorMessage in
                self?.showErrorAlert(message: errorMessage)
            }
            .store(in: &cancellables)
    }

    private func fetchInitialData() {
        Task {
            do {
                try await viewModel.fetchHobbies(status: .inProgress)
            } catch {
                // Error already handled via binding
            }
        }
    }

    // MARK: - Actions

    @objc private func segmentChanged(_ sender: UISegmentedControl) {
        let status: HobbyStatus = sender.selectedSegmentIndex == 0 ? .inProgress : .archived
        hobbySettingsView.animateUnderline(to: sender.selectedSegmentIndex)
        Task {
            await viewModel.switchSegment(to: status)
        }
    }

    /// 프로그래밍 방식으로 탭 전환
    private func switchToTab(_ status: HobbyStatus) {
        print("🔄 switchToTab called with status: \(status)")
        let index = status == .inProgress ? 0 : 1
        hobbySettingsView.segmentedControl.selectedSegmentIndex = index
        print("🔄 segmentedControl.selectedSegmentIndex set to: \(index)")
        hobbySettingsView.animateUnderline(to: index)
        print("🔄 animateUnderline called")
        Task {
            print("🔄 calling viewModel.switchSegment")
            await viewModel.switchSegment(to: status)
            print("🔄 viewModel.switchSegment completed")
        }
    }

    private func handleArchive(hobbyId: Int) {
        // Find hobby name for alert message
        guard let hobby = viewModel.hobbies.first(where: { $0.hobbyId == hobbyId }) else {
            return
        }

        let alertVC = CommonAlertViewController(
            title: "'\(hobby.hobbyName)' 취미를 보관하시겠어요?",
            message: "저장된 기록과 함께 보관함에서 다시 꺼낼 수 있어요!",
            cancelButtonTitle: "닫기",
            confirmButtonTitle: "보관",
            onCancel: nil,
            onConfirm: { [weak self] in
                self?.performArchive(hobbyId: hobbyId, hobbyName: hobby.hobbyName)
            }
        )

        present(alertVC, animated: true)
    }

    private func performArchive(hobbyId: Int, hobbyName: String) {
        Task { [weak self] in
            guard let self = self else { return }
            do {
                try await self.viewModel.archiveHobby(hobbyId: hobbyId)
                await MainActor.run {
                    // Notify other screens that a hobby was archived
                    AppEventBus.shared.hobbyDeleted.send()

                    // Show success toast with navigation action
                    ToastView.show(
                        message: "'\(hobbyName)' 취미를 보관했어요.",
                        actionTitle: "이동하기",
                        duration: 3.0,
                        onAction: { [weak self] in
                            print("🍞 Toast action tapped - archive")
                            guard let self = self else {
                                print("❌ self is nil")
                                return
                            }
                            // Switch to archived tab
                            self.switchToTab(.archived)
                        }
                    )
                }
            } catch {
                // Error already handled via binding
            }
        }
    }

    private func handleUnarchive(hobbyId: Int) {
        // Find hobby name for alert message
        guard let hobby = viewModel.hobbies.first(where: { $0.hobbyId == hobbyId }) else {
            return
        }

        let alertVC = CommonAlertViewController(
            title: "'\(hobby.hobbyName)' 취미를 꺼내시겠어요?",
            message: "저장된 기록으로 다시 '\(hobby.hobbyName)' 취미를 시작할 수 있어요!",
            cancelButtonTitle: "닫기",
            confirmButtonTitle: "꺼내기",
            onCancel: nil,
            onConfirm: { [weak self] in
                self?.performUnarchive(hobbyId: hobbyId, hobbyName: hobby.hobbyName)
            }
        )

        present(alertVC, animated: true)
    }

    private func performUnarchive(hobbyId: Int, hobbyName: String) {
        Task { [weak self] in
            guard let self = self else { return }
            do {
                try await self.viewModel.unarchiveHobby(hobbyId: hobbyId)
                await MainActor.run {
                    // Notify other screens that a hobby was restored
                    AppEventBus.shared.hobbyDeleted.send()

                    // Show success toast with navigation action
                    ToastView.show(
                        message: "'\(hobbyName)' 취미를 꺼냈어요.",
                        actionTitle: "이동하기",
                        duration: 3.0,
                        onAction: { [weak self] in
                            print("🍞 Toast action tapped - unarchive")
                            guard let self = self else {
                                print("❌ self is nil")
                                return
                            }
                            // Switch to in-progress tab
                            self.switchToTab(.inProgress)
                        }
                    )
                }
            } catch {
                // Error already handled via binding
            }
        }
    }

    private func handleTimeEdit(hobbyId: Int) {
        // Find current hobby to get current time
        guard let hobby = viewModel.hobbies.first(where: { $0.hobbyId == hobbyId }) else {
            return
        }

        // Create ViewModel
        let timeViewModel = TimeSelectionViewModel()
        // Convert minutes to time string format
        let timeString = convertMinutesToTimeString(hobby.hobbyTimeMinutes)
        timeViewModel.selectTime(timeString)

        // Create ViewController
        let timeVC = TimeSelectionViewController(viewModel: timeViewModel)
        let nav = UINavigationController(rootViewController: timeVC)
        nav.modalPresentationStyle = .fullScreen

        // Present first, then configure
        present(nav, animated: true) { [weak self, weak timeVC] in
            guard let self = self, let timeVC = timeVC else { return }

            // Hide progress bar from navigation bar
            self.hideProgressBar(in: timeVC)

            // Change to X mark button on right side
            timeVC.navigationItem.leftBarButtonItem = nil
            timeVC.navigationItem.rightBarButtonItem = UIBarButtonItem(
                image: UIImage(systemName: "xmark"),
                style: .plain,
                target: self,
                action: #selector(self.dismissPresentedViewController)
            )
            timeVC.navigationItem.rightBarButtonItem?.tintColor = .label

            // Change button text to "변경"
            var config = timeVC.nextButton.configuration
            config?.title = "변경"
            timeVC.nextButton.configuration = config

            // Override next button action
            timeVC.nextButton.removeTarget(nil, action: nil, for: .allEvents)
            timeVC.nextButton.addTarget(self, action: #selector(self.timeChangeButtonTapped(_:)), for: .touchUpInside)
            timeVC.nextButton.tag = hobbyId
        }
    }

    @objc private func timeChangeButtonTapped(_ sender: UIButton) {
        let hobbyId = sender.tag

        // Get selected time from presented ViewController
        guard let nav = presentedViewController as? UINavigationController,
              let timeVC = nav.viewControllers.first as? TimeSelectionViewController,
              let selectedTimeString = timeVC.viewModel.selectedTime else {
            return
        }

        // Convert string to minutes
        let minutes = convertTimeStringToMinutes(selectedTimeString)

        Task {
            do {
                try await viewModel.updateTime(hobbyId: hobbyId, minutes: minutes)
                await MainActor.run {
                    // Notify HomeViewController to refresh hobby info
                    AppEventBus.shared.hobbySettingsUpdated.send(hobbyId)

                    dismissPresentedViewController()
                }
            } catch {
                // Error already handled via binding
            }
        }
    }

    private func convertTimeStringToMinutes(_ time: String) -> Int {
        switch time {
        case "10": return 10
        case "20": return 20
        case "30분": return 30
        case "1시간": return 60
        case "2시간": return 120
        default: return 0
        }
    }

    private func convertMinutesToTimeString(_ minutes: Int) -> String {
        switch minutes {
        case 10: return "10"
        case 20: return "20"
        case 30: return "30분"
        case 60: return "1시간"
        case 120: return "2시간"
        default: return "30분" // Default fallback
        }
    }

    private func handleExecutionEdit(hobbyId: Int) {
        // Find current hobby to get current frequency
        guard let hobby = viewModel.hobbies.first(where: { $0.hobbyId == hobbyId }) else {
            return
        }

        // Create ViewModel
        let frequencyViewModel = FrequencySelectionViewModel()

        // Pre-select current frequency
        if let index = frequencyViewModel.frequencies.firstIndex(where: { $0.count == hobby.executionCount }) {
            frequencyViewModel.selectFrequency(at: index)
        }

        // Create ViewController
        let frequencyVC = FrequencySelectionViewController(viewModel: frequencyViewModel)
        let nav = UINavigationController(rootViewController: frequencyVC)
        nav.modalPresentationStyle = .fullScreen

        // Present first, then configure
        present(nav, animated: true) { [weak self, weak frequencyVC] in
            guard let self = self, let frequencyVC = frequencyVC else { return }

            // Hide progress bar from navigation bar
            self.hideProgressBar(in: frequencyVC)

            // Change to X mark button on right side
            frequencyVC.navigationItem.leftBarButtonItem = nil
            frequencyVC.navigationItem.rightBarButtonItem = UIBarButtonItem(
                image: UIImage(systemName: "xmark"),
                style: .plain,
                target: self,
                action: #selector(self.dismissPresentedViewController)
            )
            frequencyVC.navigationItem.rightBarButtonItem?.tintColor = .label

            // Change button text to "변경"
            var config = frequencyVC.nextButton.configuration
            config?.title = "변경"
            frequencyVC.nextButton.configuration = config

            // Override next button action
            frequencyVC.nextButton.removeTarget(nil, action: nil, for: .allEvents)
            frequencyVC.nextButton.addTarget(self, action: #selector(self.frequencyChangeButtonTapped(_:)), for: .touchUpInside)
            frequencyVC.nextButton.tag = hobbyId
        }
    }

    @objc private func frequencyChangeButtonTapped(_ sender: UIButton) {
        let hobbyId = sender.tag

        // Get selected frequency from presented ViewController
        guard let nav = presentedViewController as? UINavigationController,
              let frequencyVC = nav.viewControllers.first as? FrequencySelectionViewController,
              let selectedFrequency = frequencyVC.viewModel.selectedFrequency?.count else {
            return
        }

        Task {
            do {
                try await viewModel.updateExecutionCount(hobbyId: hobbyId, count: selectedFrequency)
                await MainActor.run {
                    // Notify HomeViewController to refresh hobby info
                    AppEventBus.shared.hobbySettingsUpdated.send(hobbyId)

                    dismissPresentedViewController()
                }
            } catch {
                // Error already handled via binding
            }
        }
    }

    private func handleGoalDaysEdit(hobbyId: Int) {
        // Find current hobby to get current goal days setting
        guard let hobby = viewModel.hobbies.first(where: { $0.hobbyId == hobbyId }) else {
            return
        }

        // Create ViewModel
        let periodViewModel = PeriodSelectionViewModel()

        // Pre-select based on current goal days
        let isDurationSet = hobby.goalDays != nil
        if let index = periodViewModel.periods.firstIndex(where: {
            $0.type == (isDurationSet ? .fixed : .flexible)
        }) {
            periodViewModel.selectPeriod(at: index)
        }

        // Create ViewController
        let periodVC = PeriodSelectionViewController(viewModel: periodViewModel)
        let nav = UINavigationController(rootViewController: periodVC)
        nav.modalPresentationStyle = .fullScreen

        // Present first, then configure
        present(nav, animated: true) { [weak self, weak periodVC] in
            guard let self = self, let periodVC = periodVC else { return }

            // Hide progress bar from navigation bar
            self.hideProgressBar(in: periodVC)

            // Change to X mark button on right side
            periodVC.navigationItem.leftBarButtonItem = nil
            periodVC.navigationItem.rightBarButtonItem = UIBarButtonItem(
                image: UIImage(systemName: "xmark"),
                style: .plain,
                target: self,
                action: #selector(self.dismissPresentedViewController)
            )
            periodVC.navigationItem.rightBarButtonItem?.tintColor = .label

            // Change button text to "변경"
            var config = periodVC.nextButton.configuration
            config?.title = "변경"
            periodVC.nextButton.configuration = config

            // Override next button action
            periodVC.nextButton.removeTarget(nil, action: nil, for: .allEvents)
            periodVC.nextButton.addTarget(self, action: #selector(self.periodChangeButtonTapped(_:)), for: .touchUpInside)
            periodVC.nextButton.tag = hobbyId
        }
    }

    @objc private func periodChangeButtonTapped(_ sender: UIButton) {
        let hobbyId = sender.tag

        // Get selected period from presented ViewController
        guard let nav = presentedViewController as? UINavigationController,
              let periodVC = nav.viewControllers.first as? PeriodSelectionViewController,
              let selectedPeriod = periodVC.viewModel.selectedPeriod else {
            return
        }

        let isDurationSet = selectedPeriod.type == .fixed

        Task {
            do {
                try await viewModel.updateGoalDays(hobbyId: hobbyId, isDurationSet: isDurationSet)
                await MainActor.run {
                    // Notify HomeViewController to refresh hobby info
                    AppEventBus.shared.hobbySettingsUpdated.send(hobbyId)

                    dismissPresentedViewController()
                }
            } catch {
                // Error already handled via binding
            }
        }
    }

    @objc private func dismissPresentedViewController() {
        presentedViewController?.dismiss(animated: true)
    }

    private func handleAddHobbyTapped() {
        // Start onboarding flow in current navigation controller
        guard let navigationController = navigationController else { return }

        // Create onboarding coordinator with current navigation controller
        // Store as property to prevent deallocation
        onboardingCoordinator = OnboardingCoordinator(navigationController: navigationController)

        // Set completion handler to pop back to HobbySettings
        onboardingCoordinator?.onHobbyCreationCompleted = { [weak self] in
            // Pop all onboarding screens and return to HobbySettings
            self?.navigationController?.popToViewController(self!, animated: true)

            // Clear onboarding coordinator reference
            self?.onboardingCoordinator = nil

            // Refresh hobby list
            Task {
                do {
                    try await self?.viewModel.fetchHobbies(status: self?.viewModel.currentStatus ?? .inProgress)
                } catch {
                    // Error already handled via binding
                }
            }
        }

        // Start onboarding flow (hobby selection)
        onboardingCoordinator?.start()
    }

    private func showErrorAlert(message: String) {
        let alert = UIAlertController(
            title: "오류",
            message: message,
            preferredStyle: .alert
        )
        alert.addAction(UIAlertAction(title: "확인", style: .default))
        present(alert, animated: true)
    }

    // MARK: - Helper Methods

    /// Progress bar를 네비게이션 바에서 찾아서 숨김 처리
    private func hideProgressBar(in viewController: UIViewController) {
        guard let navigationBar = viewController.navigationController?.navigationBar else { return }

        // 네비게이션 바의 subviews에서 GradientProgressView 찾기
        for subview in navigationBar.subviews {
            if let progressBar = subview as? GradientProgressView {
                progressBar.isHidden = true
                progressBar.removeFromSuperview()
                break
            }
        }
    }
}

// MARK: - UITableViewDataSource

extension HobbySettingsViewController: UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let hobbyCount = viewModel.hobbies.count
        let showAddCell = viewModel.showAddHobbyCell
        return hobbyCount + (showAddCell ? 1 : 0)
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        // Check if this is the "Add Hobby" cell
        if viewModel.showAddHobbyCell && indexPath.row == viewModel.hobbies.count {
            guard let cell = tableView.dequeueReusableCell(withIdentifier: AddHobbyCell.identifier, for: indexPath) as? AddHobbyCell else {
                return UITableViewCell()
            }

            cell.onTapped = { [weak self] in
                self?.handleAddHobbyTapped()
            }

            return cell
        }

        // Otherwise, return a HobbySettingsCell
        guard let cell = tableView.dequeueReusableCell(withIdentifier: HobbySettingsCell.identifier, for: indexPath) as? HobbySettingsCell else {
            return UITableViewCell()
        }

        let hobby = viewModel.hobbies[indexPath.row]
        let isArchived = viewModel.currentStatus == .archived

        cell.configure(with: hobby, isArchived: isArchived)

        // Set callbacks
        cell.onArchiveTapped = { [weak self] hobbyId in
            self?.handleArchive(hobbyId: hobbyId)
        }

        cell.onUnarchiveTapped = { [weak self] hobbyId in
            self?.handleUnarchive(hobbyId: hobbyId)
        }

        cell.onTimeEditTapped = { [weak self] hobbyId in
            self?.handleTimeEdit(hobbyId: hobbyId)
        }

        cell.onExecutionEditTapped = { [weak self] hobbyId in
            self?.handleExecutionEdit(hobbyId: hobbyId)
        }

        cell.onGoalDaysEditTapped = { [weak self] hobbyId in
            self?.handleGoalDaysEdit(hobbyId: hobbyId)
        }

        return cell
    }
}

// MARK: - UITableViewDelegate

extension HobbySettingsViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
}
