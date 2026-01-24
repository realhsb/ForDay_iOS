//
//  HobbyFilterView.swift
//  Forday
//
//  Created by Subeen on 1/23/26.
//

import UIKit
import SnapKit
import Then

final class HobbyFilterView: UIView {

    // MARK: - Properties

    private let collectionView: UICollectionView
    private var hobbies: [MyPageHobby] = []
    private var selectedHobbyId: Int? // nil = "전체" (all)

    var onHobbySelected: ((Int?) -> Void)?

    // MARK: - Initialization

    override init(frame: CGRect) {
        let flowLayout = UICollectionViewFlowLayout()
        flowLayout.scrollDirection = .horizontal
        flowLayout.minimumLineSpacing = 12
        flowLayout.minimumInteritemSpacing = 12

        self.collectionView = UICollectionView(frame: .zero, collectionViewLayout: flowLayout)

        super.init(frame: frame)

        style()
        layout()
        setupCollectionView()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Configuration

    func configure(with hobbies: [MyPageHobby]) {
        self.hobbies = hobbies
        collectionView.reloadData()
    }

    func selectHobby(_ hobbyId: Int?) {
        selectedHobbyId = hobbyId
        collectionView.reloadData()
    }
}

// MARK: - Setup

extension HobbyFilterView {
    private func style() {
        backgroundColor = .systemBackground

        collectionView.do {
            $0.backgroundColor = .clear
            $0.showsHorizontalScrollIndicator = false
        }
    }

    private func layout() {
        addSubview(collectionView)

        collectionView.snp.makeConstraints {
            $0.edges.equalToSuperview().inset(UIEdgeInsets(top: 8, left: 20, bottom: 8, right: 20))
        }
    }

    private func setupCollectionView() {
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.register(
            HobbyFilterCell.self,
            forCellWithReuseIdentifier: HobbyFilterCell.identifier
        )
    }
}

// MARK: - UICollectionViewDataSource

extension HobbyFilterView: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return hobbies.count + 1 // +1 for "전체" cell
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(
            withReuseIdentifier: HobbyFilterCell.identifier,
            for: indexPath
        ) as? HobbyFilterCell else {
            return UICollectionViewCell()
        }

        if indexPath.item == 0 {
            // "전체" cell
            cell.configureAsAll(isSelected: selectedHobbyId == nil)
        } else {
            // Hobby cell
            let hobby = hobbies[indexPath.item - 1]
            let isSelected = selectedHobbyId == hobby.hobbyId
            cell.configure(with: hobby, isSelected: isSelected)
        }

        return cell
    }
}

// MARK: - UICollectionViewDelegate

extension HobbyFilterView: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if indexPath.item == 0 {
            // Selected "전체"
            selectedHobbyId = nil
            onHobbySelected?(nil)
        } else {
            // Selected hobby
            let hobby = hobbies[indexPath.item - 1]
            selectedHobbyId = hobby.hobbyId
            onHobbySelected?(hobby.hobbyId)
        }

        collectionView.reloadData()
    }
}

// MARK: - UICollectionViewDelegateFlowLayout

extension HobbyFilterView: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: 64, height: 64)
    }
}

#Preview {
    HobbyFilterView()
}
