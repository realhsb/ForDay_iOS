//
//  ScrapGridViewController.swift
//  Forday
//
//  Created by Subeen on 2/1/26.
//

import UIKit
import SnapKit
import Then
import Combine

final class ScrapGridViewController: UIViewController {

    // MARK: - Properties

    private let viewModel: MyPageViewModel
    private var cancellables = Set<AnyCancellable>()

    weak var coordinator: MainTabBarCoordinator?

    // UI Components
    private let scrapCollectionView: UICollectionView
    private let refreshControl = UIRefreshControl()
    private let emptyStateView = EmptyStateView()

    // MARK: - Initialization

    init(viewModel: MyPageViewModel) {
        self.viewModel = viewModel

        // Setup collection view layout
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .vertical
        layout.minimumLineSpacing = 4
        layout.minimumInteritemSpacing = 4

        self.scrapCollectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)

        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        style()
        layout()
        setupCollectionView()
        bind()
    }
}

// MARK: - Setup

extension ScrapGridViewController {
    private func style() {
        view.backgroundColor = .systemBackground

        scrapCollectionView.do {
            $0.backgroundColor = .systemBackground
            $0.refreshControl = refreshControl
        }

        refreshControl.do {
            $0.addTarget(self, action: #selector(refreshScraps), for: .valueChanged)
        }
    }

    private func layout() {
        view.addSubview(scrapCollectionView)

        scrapCollectionView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
    }

    private func setupCollectionView() {
        scrapCollectionView.delegate = self
        scrapCollectionView.dataSource = self
        scrapCollectionView.register(
            ActivityPhotoCell.self,
            forCellWithReuseIdentifier: ActivityPhotoCell.identifier
        )
    }

    private func bind() {
        // Scraps
        viewModel.$scraps
            .receive(on: DispatchQueue.main)
            .sink { [weak self] scraps in
                self?.scrapCollectionView.reloadData()
                self?.updateEmptyState(hasScraps: !scraps.isEmpty)
            }
            .store(in: &cancellables)

        // Loading state
        viewModel.$isLoading
            .receive(on: DispatchQueue.main)
            .sink { [weak self] isLoading in
                if !isLoading {
                    self?.refreshControl.endRefreshing()
                }
            }
            .store(in: &cancellables)
    }
}

// MARK: - Actions

extension ScrapGridViewController {
    @objc private func refreshScraps() {
        Task {
            await viewModel.refreshScraps()
        }
    }

    private func updateEmptyState(hasScraps: Bool) {
        if hasScraps {
            emptyStateView.removeFromSuperview()
        } else {
            guard emptyStateView.superview == nil else { return }
            view.addSubview(emptyStateView)
            emptyStateView.snp.makeConstraints {
                $0.edges.equalToSuperview()
            }

            emptyStateView.configure(
                icon: UIImage(systemName: "bookmark"),
                message: "스크랩한 활동이 없습니다.\n마음에 드는 활동을 스크랩해보세요!",
                actionTitle: nil
            )
        }
    }
}

// MARK: - UICollectionViewDataSource

extension ScrapGridViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return viewModel.scraps.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(
            withReuseIdentifier: ActivityPhotoCell.identifier,
            for: indexPath
        ) as? ActivityPhotoCell else {
            return UICollectionViewCell()
        }

        let scrap = viewModel.scraps[indexPath.item]
        cell.configure(with: scrap)

        return cell
    }
}

// MARK: - UICollectionViewDelegate

extension ScrapGridViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let scrap = viewModel.scraps[indexPath.item]
        showActivityDetail(activityRecordId: scrap.recordId)
    }

    private func showActivityDetail(activityRecordId: Int) {
        let detailViewModel = ActivityDetailViewModel(activityRecordId: activityRecordId)
        let detailVC = ActivityDetailViewController(viewModel: detailViewModel)
        detailVC.coordinator = coordinator

        // Push to navigation stack
        if let navController = parent?.navigationController {
            navController.pushViewController(detailVC, animated: true)
        }
    }

    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let offsetY = scrollView.contentOffset.y
        let contentHeight = scrollView.contentSize.height
        let height = scrollView.frame.size.height

        // Load more when scrolled to 80% of content
        // Prevent duplicate calls by checking isLoadingMore
        if offsetY > contentHeight - height * 1.2 && !viewModel.isLoadingMore {
            Task {
                await viewModel.loadMoreScraps()
            }
        }
    }
}

// MARK: - UICollectionViewDelegateFlowLayout

extension ScrapGridViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let numberOfColumns: CGFloat = 3
        let spacing: CGFloat = 4 // minimumInteritemSpacing
        let inset: CGFloat = 4 // left + right insets

        // Calculate total spacing between items (2 spacings for 3 columns)
        let totalSpacing = spacing * (numberOfColumns - 1)
        let totalInsets = inset * 2

        // Calculate available width
        let availableWidth = collectionView.bounds.width - totalSpacing - totalInsets
        let itemWidth = floor(availableWidth / numberOfColumns)

        // Aspect ratio: 119:128 (slightly taller than square)
        let itemHeight = floor(itemWidth * 128 / 119)

        return CGSize(width: itemWidth, height: itemHeight)
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: 4, left: 4, bottom: 4, right: 4)
    }
}
