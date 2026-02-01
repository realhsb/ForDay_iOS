//
//  ManageHobbyCoverView.swift
//  Forday
//
//  Created by Subeen on 1/27/26.
//

import UIKit
import SnapKit
import Then

final class ManageHobbyCoverView: UIView {

    // MARK: - Properties

    // Hobby List Section
    private let hobbyListContainerView = UIView()
    private let hobbyCountLabel = UILabel()
    let hobbyCollectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        layout.minimumInteritemSpacing = 16
        layout.minimumLineSpacing = 16
        layout.sectionInset = UIEdgeInsets(top: 0, left: 20, bottom: 0, right: 20)

        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.backgroundColor = .clear
        collectionView.showsHorizontalScrollIndicator = false
        return collectionView
    }()

    // Feed Grid Section
    let feedCollectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .vertical
        layout.minimumInteritemSpacing = 4
        layout.minimumLineSpacing = 4

        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.backgroundColor = .systemBackground
        return collectionView
    }()

    // Empty State
    let emptyStateLabel = UILabel()

    // MARK: - Initialization

    override init(frame: CGRect) {
        super.init(frame: frame)
        style()
        layout()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

// MARK: - Setup

extension ManageHobbyCoverView {
    private func style() {
        backgroundColor = .systemBackground

        hobbyListContainerView.do {
            $0.backgroundColor = .clear
        }

        hobbyCountLabel.do {
            $0.font = .systemFont(ofSize: 14, weight: .medium)
            $0.textColor = .secondaryLabel
        }

        hobbyCollectionView.do {
            $0.register(HobbyCoverCell.self, forCellWithReuseIdentifier: "HobbyCoverCell")
        }

        feedCollectionView.do {
            $0.register(FeedItemCell.self, forCellWithReuseIdentifier: "FeedItemCell")
            $0.showsVerticalScrollIndicator = true
        }

        emptyStateLabel.do {
            $0.text = "활동 기록이 없습니다"
            $0.font = .systemFont(ofSize: 14, weight: .regular)
            $0.textColor = .secondaryLabel
            $0.textAlignment = .center
            $0.isHidden = true
        }
    }

    private func layout() {
        addSubview(hobbyListContainerView)
        hobbyListContainerView.addSubview(hobbyCountLabel)
        hobbyListContainerView.addSubview(hobbyCollectionView)

        addSubview(feedCollectionView)
        addSubview(emptyStateLabel)

        // Hobby List Container
        hobbyListContainerView.snp.makeConstraints {
            $0.top.equalTo(safeAreaLayoutGuide)
            $0.leading.trailing.equalToSuperview()
            $0.height.equalTo(140)
        }

        hobbyCountLabel.snp.makeConstraints {
            $0.top.equalToSuperview().offset(16)
            $0.leading.equalToSuperview().offset(20)
        }

        hobbyCollectionView.snp.makeConstraints {
            $0.top.equalTo(hobbyCountLabel.snp.bottom).offset(12)
            $0.leading.trailing.equalToSuperview()
            $0.bottom.equalToSuperview().offset(-8)
        }

        // Feed Collection View
        feedCollectionView.snp.makeConstraints {
            $0.top.equalTo(hobbyListContainerView.snp.bottom)
            $0.leading.equalToSuperview().offset(20)
            $0.trailing.equalToSuperview().offset(-20)
            $0.bottom.equalTo(safeAreaLayoutGuide)
        }

        // Empty State
        emptyStateLabel.snp.makeConstraints {
            $0.center.equalTo(feedCollectionView)
        }
    }
}

// MARK: - Public Methods

extension ManageHobbyCoverView {
    func updateHobbyCount(_ count: Int) {
        hobbyCountLabel.text = "\(count)개"
    }

    func showEmptyState(_ show: Bool) {
        emptyStateLabel.isHidden = !show
        feedCollectionView.isHidden = show
    }
}
