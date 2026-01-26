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

        // Error message
        viewModel.$errorMessage
            .receive(on: DispatchQueue.main)
            .sink { [weak self] errorMessage in
                if let error = errorMessage {
                    print("❌ Error: \(error)")
                    self?.showError(error)
                }
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
    ActivityDetailViewController(viewModel: .init(activityRecordId: 1))
}
