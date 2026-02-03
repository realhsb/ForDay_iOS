//
//  ActivityDetailViewController.swift
//  Forday
//
//  Created by Subeen on 1/23/26.
//

import UIKit
import SnapKit
import Then
import Combine

final class ActivityDetailViewController: UIViewController, UIGestureRecognizerDelegate {

    // MARK: - Properties

    private var detailView: ActivityDetailView {
        return view as! ActivityDetailView
    }

    private let viewModel: ActivityDetailViewModel
    private var cancellables = Set<AnyCancellable>()
    private var dropdownView: ActivityDetailDropdownView?

    weak var coordinator: MainTabBarCoordinator?

    // MARK: - Initialization

    init(viewModel: ActivityDetailViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
        hidesBottomBarWhenPushed = true
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Lifecycle

    override func loadView() {
        view = ActivityDetailView()
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        setupNavigationBar()
        setupGestures()
        bind()
        loadData()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(false, animated: animated)
        navigationController?.interactivePopGestureRecognizer?.delegate = self
        navigationController?.interactivePopGestureRecognizer?.isEnabled = true
    }

    // MARK: - UIGestureRecognizerDelegate

    func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
        return navigationController?.viewControllers.count ?? 0 > 1
    }
}

// MARK: - Setup

extension ActivityDetailViewController {
    private func setupNavigationBar() {
        title = "내 활동 보기"

        // Back button with custom chevronLeft icon
        let backButton = UIBarButtonItem(
            image: .Icon.chevronLeft,
            style: .plain,
            target: self,
            action: #selector(backButtonTapped)
        )
        backButton.tintColor = .label
        navigationItem.leftBarButtonItem = backButton

        // Hide the default back button
        navigationItem.hidesBackButton = true

        // More button with 3dot icon
        let moreButton = UIBarButtonItem(
            image: .Icon.threeDot,
            style: .plain,
            target: self,
            action: #selector(moreButtonTapped)
        )
        moreButton.tintColor = .label

        navigationItem.rightBarButtonItem = moreButton
    }

    @objc private func backButtonTapped() {
        navigationController?.popViewController(animated: true)
    }

    private func setupGestures() {
        // Background tap to dismiss dropdown
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(backgroundTapped))
        tapGesture.cancelsTouchesInView = false
        view.addGestureRecognizer(tapGesture)
    }

    private func bind() {
        // Activity detail
        viewModel.$activityDetail
            .receive(on: DispatchQueue.main)
            .sink { [weak self] detail in
                guard let detail = detail else { return }
                self?.detailView.configure(with: detail)
            }
            .store(in: &cancellables)

        // Loading state
        viewModel.$isLoading
            .receive(on: DispatchQueue.main)
            .sink { isLoading in
                if isLoading {
                    print("🔄 Loading activity detail...")
                } else {
                    print("✅ Activity detail loaded")
                }
            }
            .store(in: &cancellables)

        // Error handling
        viewModel.$error
            .receive(on: DispatchQueue.main)
            .compactMap { $0 }
            .sink { [weak self] error in
                // Use common error handler with retry support
                self?.handleActivityDetailError(error) {
                    self?.loadData()
                }
            }
            .store(in: &cancellables)

        // Reaction button single tapped (show users)
        detailView.reactionButtonsView.reactionSingleTapped
            .sink { [weak self] reactionType in
                self?.handleReactionSingleTapped(reactionType)
            }
            .store(in: &cancellables)

        // Reaction button double tapped (toggle reaction)
        detailView.reactionButtonsView.reactionDoubleTapped
            .sink { [weak self] reactionType in
                self?.handleReactionDoubleTapped(reactionType)
            }
            .store(in: &cancellables)

        // Reaction users
        viewModel.$reactionUsers
            .receive(on: DispatchQueue.main)
            .sink { [weak self] users in
                guard let self = self else { return }

                if users.isEmpty {
                    self.detailView.reactionUsersScrollView.isHidden = true
                    self.detailView.reactionUsersScrollView.clear()

                    // Collapse height when hidden
                    self.detailView.reactionUsersScrollView.snp.updateConstraints {
                        $0.height.equalTo(0)
                    }
                } else {
                    self.detailView.reactionUsersScrollView.isHidden = false
                    self.detailView.reactionUsersScrollView.configure(with: users)

                    // Expand height when visible
                    self.detailView.reactionUsersScrollView.snp.updateConstraints {
                        $0.height.equalTo(60)
                    }
                }

                // Animate layout change
                UIView.animate(withDuration: 0.3) {
                    self.view.layoutIfNeeded()
                }
            }
            .store(in: &cancellables)

        // Bookmark button tapped
        detailView.reactionButtonsView.bookmarkTapped
            .sink { [weak self] in
                self?.handleBookmarkTapped()
            }
            .store(in: &cancellables)
    }

    private func loadData() {
        Task {
            await viewModel.fetchDetail()
        }
    }
}

// MARK: - Actions

extension ActivityDetailViewController {
    @objc private func moreButtonTapped() {
        print("⋯ More button tapped")

        // Dismiss dropdown if already showing
        if dropdownView != nil {
            dismissDropdown()
            return
        }

        // Show custom dropdown
        showDropdown()
    }

    @objc private func backgroundTapped() {
        dismissDropdown()
    }

    private func showDropdown() {
        guard dropdownView == nil,
              let moreButton = navigationItem.rightBarButtonItem,
              let barButtonView = moreButton.value(forKey: "view") as? UIView else {
            return
        }

        let dropdown = ActivityDetailDropdownView()
        dropdown.onOptionSelected = { [weak self] option in
            self?.handleDropdownOption(option)
            self?.dismissDropdown()
        }

        dropdown.show(in: view, below: barButtonView)
        dropdownView = dropdown
    }

    private func dismissDropdown() {
        dropdownView?.dismiss()
        dropdownView = nil
    }

    private func handleDropdownOption(_ option: ActivityDetailDropdownOption) {
        switch option {
        case .setCoverImage:
            setAsProfileImage()
        case .edit:
            editActivity()
        case .delete:
            showDeleteConfirmation()
        }
    }

    private func setAsProfileImage() {
        guard let detail = viewModel.activityDetail else { return }

        print("📸 대표사진 설정: \(detail.imageUrl)")

        Task {
            do {
                try await viewModel.setCoverImage()
                await MainActor.run {
                    print("✅ 대표사진 설정 성공")
                    showSuccessAlert(
                        title: "완료",
                        message: "대표사진이 설정되었습니다."
                    )
                }
            } catch let appError as AppError {
                await MainActor.run {
                    print("❌ 대표사진 설정 실패: \(appError)")
                    handleError(appError)
                }
            } catch {
                await MainActor.run {
                    print("❌ 대표사진 설정 실패: \(error)")
                    handleError(.unknown(error))
                }
            }
        }
    }

    private func editActivity() {
        guard let detail = viewModel.activityDetail else { return }

        print("✏️ 수정하기")

        // ActivityRecordViewController를 수정 모드로 열기
        let recordVC = ActivityRecordViewController(hobbyId: viewModel.hobbyId, activityDetail: detail)
        let nav = UINavigationController(rootViewController: recordVC)
        nav.modalPresentationStyle = .fullScreen

        present(nav, animated: true)
    }

    private func showDeleteConfirmation() {
        print("🗑️ 삭제 확인 팝업 표시")

        let alertVC = CommonAlertViewController(
            title: "활동 기록 삭제",
            message: "정말 이 활동 기록을\n삭제하시겠어요?",
            cancelButtonTitle: "취소",
            confirmButtonTitle: "삭제",
            onCancel: {
                print("취소 선택")
            },
            onConfirm: { [weak self] in
                self?.deleteActivity()
            }
        )

        present(alertVC, animated: true)
    }

    private func deleteActivity() {
        print("🗑️ 활동 기록 삭제")

        Task {
            do {
                try await viewModel.deleteRecord()
                await MainActor.run {
                    print("✅ 활동 기록 삭제 성공")

                    // Notify observers that a record was deleted
                    if let detail = viewModel.activityDetail {
                        AppEventBus.shared.activityRecordCreated.send(detail.hobbyId)
                    }

                    // Navigate back
                    navigationController?.popViewController(animated: true)
                }
            } catch let appError as AppError {
                await MainActor.run {
                    print("❌ 활동 기록 삭제 실패: \(appError)")
                    handleError(appError)
                }
            } catch {
                await MainActor.run {
                    print("❌ 활동 기록 삭제 실패: \(error)")
                    handleError(.unknown(error))
                }
            }
        }
    }

    private func handleError(_ error: AppError) {
        let alert = UIAlertController(
            title: "오류",
            message: error.userMessage,
            preferredStyle: .alert
        )
        alert.addAction(UIAlertAction(title: "확인", style: .default))
        present(alert, animated: true)
    }

    private func showSuccessAlert(title: String, message: String) {
        let alert = UIAlertController(
            title: title,
            message: message,
            preferredStyle: .alert
        )
        alert.addAction(UIAlertAction(title: "확인", style: .default))
        present(alert, animated: true)
    }

    private func handleReactionSingleTapped(_ reactionType: ReactionType) {
        print("👆 \(reactionType.displayName) 반응 버튼 단일 탭 - 유저 목록 표시")

        Task {
            await viewModel.fetchReactionUsers(for: reactionType)
        }
    }

    private func handleReactionDoubleTapped(_ reactionType: ReactionType) {
        print("👆👆 \(reactionType.displayName) 반응 버튼 더블 탭 - 반응 추가/삭제")

        Task {
            await viewModel.toggleReaction(reactionType)
        }
    }

    private func handleBookmarkTapped() {
        print("🔖 북마크 버튼 탭 - 스크랩 추가/삭제")

        Task {
            await viewModel.toggleScrap()
        }
    }

}

#if DEBUG
#Preview("ActivityDetailViewController - Basic") {
    let viewModel = ActivityDetailViewModel(activityRecordId: 1)
    let vc = ActivityDetailViewController(viewModel: viewModel)

    // Manually configure view with mock data (bypass network call)
    vc.loadViewIfNeeded()
    (vc.view as? ActivityDetailView)?.configure(with: .preview)

    let nav = UINavigationController(rootViewController: vc)
    return nav
}

#Preview("ActivityDetailViewController - Scraped") {
    let viewModel = ActivityDetailViewModel(activityRecordId: 2)
    let vc = ActivityDetailViewController(viewModel: viewModel)

    vc.loadViewIfNeeded()
    (vc.view as? ActivityDetailView)?.configure(with: .previewScraped)

    let nav = UINavigationController(rootViewController: vc)
    return nav
}

#Preview("ActivityDetailViewController - All Reactions") {
    let viewModel = ActivityDetailViewModel(activityRecordId: 3)
    let vc = ActivityDetailViewController(viewModel: viewModel)

    vc.loadViewIfNeeded()
    (vc.view as? ActivityDetailView)?.configure(with: .previewWithAllReactions)

    let nav = UINavigationController(rootViewController: vc)
    return nav
}
#endif
