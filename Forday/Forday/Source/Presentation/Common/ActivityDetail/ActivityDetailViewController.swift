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

final class ActivityDetailViewController: UIViewController {

    // MARK: - Properties

    private var detailView: ActivityDetailView {
        return view as! ActivityDetailView
    }

    private let viewModel: ActivityDetailViewModel
    private var cancellables = Set<AnyCancellable>()

    weak var coordinator: MainTabBarCoordinator?

    // MARK: - Initialization

    init(viewModel: ActivityDetailViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
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
        bind()
        loadData()
    }
}

// MARK: - Setup

extension ActivityDetailViewController {
    private func setupNavigationBar() {
        title = "내 활동 보기"

        // More button
        let moreButton = UIBarButtonItem(
            image: UIImage(systemName: "ellipsis"),
            style: .plain,
            target: self,
            action: #selector(moreButtonTapped)
        )
        moreButton.tintColor = .label

        navigationItem.rightBarButtonItem = moreButton
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
                self?.handleError(error)
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
        // TODO: Show more options (edit, delete, share, etc.)
        print("⋯ More button tapped")

        let alert = UIAlertController(
            title: nil,
            message: nil,
            preferredStyle: .actionSheet
        )

        alert.addAction(UIAlertAction(title: "수정하기", style: .default) { _ in
            print("✏️ Edit activity")
        })

        alert.addAction(UIAlertAction(title: "삭제하기", style: .destructive) { _ in
            print("🗑️ Delete activity")
        })

        alert.addAction(UIAlertAction(title: "취소", style: .cancel))

        present(alert, animated: true)
    }

    private func handleError(_ error: AppError) {
        print("❌ Error: \(error)")

        let title: String
        let message = error.userMessage
        var actions: [UIAlertAction] = []

        switch error {
        case .network(let networkError):
            title = "네트워크 오류"
            // Add retry action for network errors
            actions.append(UIAlertAction(title: "다시 시도", style: .default) { [weak self] _ in
                self?.loadData()
            })
            actions.append(UIAlertAction(title: "취소", style: .cancel))

        case .server(let serverError):
            // Handle specific server errors
            switch serverError.errorClassName {
            case "ACTIVITY_RECORD_NOT_FOUND":
                title = "활동 기록을 찾을 수 없음"
                actions.append(UIAlertAction(title: "확인", style: .default) { [weak self] _ in
                    self?.navigationController?.popViewController(animated: true)
                })

            case "FRIEND_ONLY_ACCESS":
                title = "접근 권한 없음"
                actions.append(UIAlertAction(title: "확인", style: .default) { [weak self] _ in
                    self?.navigationController?.popViewController(animated: true)
                })

            case "PRIVATE_RECORD":
                title = "비공개 게시글"
                actions.append(UIAlertAction(title: "확인", style: .default) { [weak self] _ in
                    self?.navigationController?.popViewController(animated: true)
                })

            default:
                title = "오류"
                actions.append(UIAlertAction(title: "확인", style: .default))
            }

        case .decoding, .unknown:
            title = "오류"
            actions.append(UIAlertAction(title: "확인", style: .default))
        }

        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        actions.forEach { alert.addAction($0) }
        present(alert, animated: true)
    }
}

#Preview {
    ActivityDetailViewController(viewModel: .init(activityRecordId: 1))
}
