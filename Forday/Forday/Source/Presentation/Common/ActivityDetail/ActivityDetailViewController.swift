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
                // Use common error handler with retry support
                self?.handleActivityDetailError(error) {
                    self?.loadData()
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
        print("⋯ More button tapped")

        let alert = UIAlertController(
            title: nil,
            message: nil,
            preferredStyle: .actionSheet
        )

        alert.addAction(UIAlertAction(title: "대표사진 설정", style: .default) { [weak self] _ in
            self?.setAsProfileImage()
        })

        alert.addAction(UIAlertAction(title: "수정하기", style: .default) { [weak self] _ in
            self?.editActivity()
        })

        alert.addAction(UIAlertAction(title: "삭제하기", style: .destructive) { [weak self] _ in
            self?.showDeleteConfirmation()
        })

        alert.addAction(UIAlertAction(title: "취소", style: .cancel))

        present(alert, animated: true)
    }

    private func setAsProfileImage() {
        guard let detail = viewModel.activityDetail else { return }

        print("📸 대표사진 설정: \(detail.imageUrl)")

        // TODO: UpdateProfileUseCase 호출
        // - 이미지 URL을 프로필 이미지로 설정
        // - API가 준비되면 구현
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

        // TODO: 삭제 API 호출
        // - API가 준비되면 구현
        // - 성공 시 이전 화면으로 이동
    }

}

#Preview {
    ActivityDetailViewController(viewModel: .init(activityRecordId: 1))
}
