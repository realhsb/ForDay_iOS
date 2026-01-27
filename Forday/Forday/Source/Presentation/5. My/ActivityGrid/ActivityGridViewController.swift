//
//  ActivityGridViewController.swift
//  Forday
//
//  Created by Subeen on 1/23/26.
//

import UIKit
import SnapKit
import Then
import Combine

final class ActivityGridViewController: UIViewController {

    // MARK: - Properties

    private let viewModel: MyPageViewModel
    private var cancellables = Set<AnyCancellable>()

    weak var coordinator: MainTabBarCoordinator?

    // UI Components
    private let hobbyFilterView = HobbyFilterView()
    private let activityCollectionView: UICollectionView
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

        self.activityCollectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)

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
        setupHobbyFilter()
        bind()
    }
}

// MARK: - Setup

extension ActivityGridViewController {
    private func style() {
        view.backgroundColor = .systemBackground

        activityCollectionView.do {
            $0.backgroundColor = .systemBackground
            $0.refreshControl = refreshControl
        }

        refreshControl.do {
            $0.addTarget(self, action: #selector(refreshActivities), for: .valueChanged)
        }
    }

    private func layout() {
        view.addSubview(hobbyFilterView)
        view.addSubview(activityCollectionView)

        hobbyFilterView.snp.makeConstraints {
            $0.top.leading.trailing.equalToSuperview()
            $0.height.equalTo(80)
        }

        activityCollectionView.snp.makeConstraints {
            $0.top.equalTo(hobbyFilterView.snp.bottom)
            $0.leading.trailing.bottom.equalToSuperview()
        }
    }

    private func setupCollectionView() {
        activityCollectionView.delegate = self
        activityCollectionView.dataSource = self
        activityCollectionView.register(
            ActivityPhotoCell.self,
            forCellWithReuseIdentifier: ActivityPhotoCell.identifier
        )
    }

    private func setupHobbyFilter() {
        hobbyFilterView.onHobbySelected = { [weak self] hobbyId in
            Task {
                await self?.viewModel.filterByHobby(hobbyId: hobbyId)
            }
        }
    }

    private func bind() {
        // Activities
        viewModel.$activities
            .receive(on: DispatchQueue.main)
            .sink { [weak self] activities in
                self?.activityCollectionView.reloadData()
                self?.updateEmptyState(hasActivities: !activities.isEmpty)
            }
            .store(in: &cancellables)

        // Hobbies for filter
        viewModel.$myHobbies
            .receive(on: DispatchQueue.main)
            .sink { [weak self] hobbies in
                self?.hobbyFilterView.configure(with: hobbies)
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

extension ActivityGridViewController {
    @objc private func refreshActivities() {
        Task {
            await viewModel.refreshActivities()
        }
    }

    private func updateEmptyState(hasActivities: Bool) {
        if hasActivities {
            emptyStateView.removeFromSuperview()
        } else {
            view.addSubview(emptyStateView)
            emptyStateView.snp.makeConstraints {
                $0.top.equalTo(hobbyFilterView.snp.bottom)
                $0.leading.trailing.bottom.equalToSuperview()
            }

            emptyStateView.configure(
                icon: UIImage(systemName: "photo.on.rectangle.angled"),
                message: "아직 기록한 활동이 없습니다.\n취미 활동을 기록해보세요!",
                actionTitle: nil
            )
        }
    }
}

// MARK: - UICollectionViewDataSource

extension ActivityGridViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return viewModel.activities.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(
            withReuseIdentifier: ActivityPhotoCell.identifier,
            for: indexPath
        ) as? ActivityPhotoCell else {
            return UICollectionViewCell()
        }

        let activity = viewModel.activities[indexPath.item]
        cell.configure(with: activity)

        return cell
    }
}

// MARK: - UICollectionViewDelegate

extension ActivityGridViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let activity = viewModel.activities[indexPath.item]
        showActivityDetail(activityRecordId: activity.recordId)
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
                await viewModel.loadMoreActivities()
            }
        }
    }
}

// MARK: - UICollectionViewDelegateFlowLayout

extension ActivityGridViewController: UICollectionViewDelegateFlowLayout {
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
        let itemHeight = itemWidth

        return CGSize(width: itemWidth, height: itemHeight)
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: 4, left: 4, bottom: 4, right: 4)
    }
}

#Preview {
    MyPageViewController()
}
