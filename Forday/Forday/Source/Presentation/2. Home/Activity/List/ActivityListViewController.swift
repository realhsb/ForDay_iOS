//
//  ActivityListViewController.swift
//  Forday
//
//  Created by Subeen on 1/16/26.
//


import UIKit
import Combine
import SnapKit

class ActivityListViewController: UIViewController {
    
    // Properties

    private let listView = ActivityListView()
    private let viewModel: ActivityListViewModel
    private let hobbyId: Int
    private var cancellables = Set<AnyCancellable>()

    // Coordinator
    weak var coordinator: MainTabBarCoordinator?

    // AI Recommendation Toast
    var shouldShowAIRecommendationToast = false
    private var aiToastView: AIRecommendationToastView?

    // Modal Presentation
    var isPresentedModally = false

    // Initialization
    
    init(hobbyId: Int, viewModel: ActivityListViewModel = ActivityListViewModel()) {
        self.hobbyId = hobbyId
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // Lifecycle
    
    override func loadView() {
        view = listView
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupNavigationBar()
        setupTableView()
        bind()
        loadActivities()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        // Show AI recommendation toast if needed
        if shouldShowAIRecommendationToast {
            shouldShowAIRecommendationToast = false
            showAIRecommendationToast()
        }
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(false, animated: animated)
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        // HomeViewController로 돌아갈 때 네비게이션 바 숨기기
        if isMovingFromParent {
            navigationController?.setNavigationBarHidden(true, animated: animated)
        }
    }
}

// Setup

extension ActivityListViewController {
    private func setupNavigationBar() {
        title = "활동 리스트"

        // Close button (when presented modally)
        if isPresentedModally {
            let closeButton = UIBarButtonItem(
                image: UIImage(systemName: "xmark"),
                style: .plain,
                target: self,
                action: #selector(closeButtonTapped)
            )
            closeButton.tintColor = .neutral800
            navigationItem.leftBarButtonItem = closeButton
        }

        // + 버튼
        let addButton = UIBarButtonItem(
            image: .Icon.plus,
            style: .plain,
            target: self,
            action: #selector(addButtonTapped)
        )
        addButton.tintColor = .neutral800
        navigationItem.rightBarButtonItem = addButton
    }
    
    private func setupTableView() {
        listView.tableView.delegate = self
        listView.tableView.dataSource = self
    }
    
    private func bind() {
        // 활동 목록 업데이트
        viewModel.$activities
            .receive(on: DispatchQueue.main)
            .sink { [weak self] _ in
                self?.listView.tableView.reloadData()
                self?.updateEmptyState()
            }
            .store(in: &cancellables)

        // 로딩 상태
        viewModel.$isLoading
            .receive(on: DispatchQueue.main)
            .sink { [weak self] isLoading in
                // TODO: 로딩 인디케이터
                print(isLoading ? "로딩 중..." : "로딩 완료")
            }
            .store(in: &cancellables)

        // 에러 처리
        viewModel.$error
            .receive(on: DispatchQueue.main)
            .compactMap { $0 }
            .sink { [weak self] error in
                self?.handleError(error)
            }
            .store(in: &cancellables)
    }
    
    private func loadActivities() {
        Task {
            await viewModel.fetchActivities(hobbyId: hobbyId)
        }
    }
    
    private func updateEmptyState() {
        listView.setEmptyState(viewModel.activities.isEmpty)
    }
}

// Actions

extension ActivityListViewController {
    @objc private func closeButtonTapped() {
        dismiss(animated: true)
    }

    @objc private func addButtonTapped() {
        let inputVC = HobbyActivityInputViewController(hobbyId: hobbyId)
        inputVC.onActivityCreated = { [weak self] in
            self?.loadActivities()  // 목록 새로고침
        }
        
        let nav = UINavigationController(rootViewController: inputVC)
        nav.modalPresentationStyle = .fullScreen
        present(nav, animated: true)
    }
    
    private func showEditAlert(for activity: Activity) {
        let alert = UIAlertController(
            title: "활동 수정",
            message: nil,
            preferredStyle: .alert
        )
        
        alert.addTextField { textField in
            textField.text = activity.content
            textField.placeholder = "활동 내용"
        }
        
        alert.addAction(UIAlertAction(title: "취소", style: .cancel))
        alert.addAction(UIAlertAction(title: "수정", style: .default) { [weak self] _ in
            guard let content = alert.textFields?.first?.text, !content.isEmpty else { return }
            self?.updateActivity(activityId: activity.activityId, content: content)
        })
        
        present(alert, animated: true)
    }
    
    private func showDeleteAlert(for activity: Activity) {
        let alert = UIAlertController(
            title: "활동 삭제",
            message: "정말 삭제하시겠습니까?",
            preferredStyle: .alert
        )
        
        alert.addAction(UIAlertAction(title: "취소", style: .cancel))
        alert.addAction(UIAlertAction(title: "삭제", style: .destructive) { [weak self] _ in
            self?.deleteActivity(activityId: activity.activityId)
        })
        
        present(alert, animated: true)
    }
    
    private func updateActivity(activityId: Int, content: String) {
        Task {
            do {
                try await viewModel.updateActivity(activityId: activityId, content: content)
                await viewModel.fetchActivities(hobbyId: hobbyId)  // 새로고침

                // 홈 화면 업데이트를 위한 이벤트 발생
                await MainActor.run {
                    AppEventBus.shared.activityUpdated.send(hobbyId)
                }
            } catch {
                await MainActor.run {
                    showError(error.localizedDescription)
                }
            }
        }
    }

    private func deleteActivity(activityId: Int) {
        Task {
            do {
                try await viewModel.deleteActivity(activityId: activityId)

                // 홈 화면 업데이트를 위한 이벤트 발생
                await MainActor.run {
                    AppEventBus.shared.activityDeleted.send(hobbyId)
                }
            } catch {
                await MainActor.run {
                    showError(error.localizedDescription)
                }
            }
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
                self?.loadActivities()
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

    private func showAIRecommendationToast() {
        let toast = AIRecommendationToastView()
        toast.configure(with: "포데이 AI가 알맞은 취미활동을 추천해드려요")

        // Set tap callback
        toast.onTap = { [weak self] in
            self?.aiToastTapped()
        }

        // Add to view
        view.addSubview(toast)
        toast.snp.makeConstraints {
            $0.leading.trailing.equalToSuperview().inset(20)
            $0.bottom.equalTo(view.safeAreaLayoutGuide).offset(-20)
        }

        // Expand animation
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            toast.expand(animated: true)
        }

        aiToastView = toast
    }

    private func aiToastTapped() {
        // Show AI recommendation loading
        showAIRecommendationFlow()
    }

    private func showAIRecommendationFlow() {
        // Show loading view
        let loadingVC = AIRecommendationLoadingViewController(hobbyId: hobbyId)
        loadingVC.modalPresentationStyle = .fullScreen
        present(loadingVC, animated: true)

        // Fetch AI recommendations
        Task {
            do {
                let aiRecommendations = try await viewModel.fetchAIRecommendations(hobbyId: hobbyId)

                await MainActor.run {
                    // Dismiss loading and show selection
                    self.dismiss(animated: true) {
                        self.showAISelectionView(with: aiRecommendations)
                    }
                }
            } catch {
                await MainActor.run {
                    self.dismiss(animated: true) {
                        self.showError(error.localizedDescription)
                    }
                }
            }
        }
    }

    private func showAISelectionView(with result: AIRecommendationResult) {
        let selectionView = AIActivitySelectionView(result: result)
        selectionView.onActivitySelected = { [weak self] activity in
            self?.saveAIRecommendedActivity(activity)
        }

        selectionView.onRefreshTapped = { [weak self] in
            self?.dismiss(animated: true) {
                self?.showAIRecommendationFlow()
            }
        }

        // Show as modal
        let containerVC = UIViewController()
        containerVC.view = selectionView
        containerVC.modalPresentationStyle = .pageSheet

        if let sheet = containerVC.sheetPresentationController {
            sheet.detents = [.large()]
            sheet.prefersGrabberVisible = true
        }

        present(containerVC, animated: true)
    }

    private func saveAIRecommendedActivity(_ activity: AIRecommendation) {
        Task {
            do {
                let activityInputs = [ActivityInput(aiRecommended: true, content: activity.content)]
                try await viewModel.createActivities(hobbyId: hobbyId, activities: activityInputs)

                await MainActor.run {
                    // Dismiss AI selection view
                    self.dismiss(animated: true)

                    // Refresh activity list
                    self.loadActivities()
                }
            } catch {
                await MainActor.run {
                    self.showError(error.localizedDescription)
                }
            }
        }
    }
}

// UITableViewDataSource

extension ActivityListViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.activities.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: ActivityCardCell.identifier, for: indexPath) as? ActivityCardCell else {
            return UITableViewCell()
        }

        let activity = viewModel.activities[indexPath.row]
        cell.configure(with: activity)

        cell.onEditTapped = { [weak self] in
            self?.showEditAlert(for: activity)
        }

        cell.onDeleteTapped = { [weak self] in
            self?.showDeleteAlert(for: activity)
        }

        return cell
    }
}

// UITableViewDelegate

extension ActivityListViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        let isExpanded = viewModel.isExpanded(at: indexPath.row)
        return isExpanded ? ActivityCardCell.expandedHeight : ActivityCardCell.collapsedHeight
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)

        viewModel.toggleExpansion(at: indexPath.row)

        // 애니메이션과 함께 셀 높이 업데이트
        tableView.beginUpdates()
        tableView.endUpdates()
    }
}

#Preview {
    let listVC = ActivityListViewController(hobbyId: 1)
    let nav = UINavigationController(rootViewController: listVC)
    return nav
}
