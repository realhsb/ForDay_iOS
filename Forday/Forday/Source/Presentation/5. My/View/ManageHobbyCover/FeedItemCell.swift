//
//  FeedItemCell.swift
//  Forday
//
//  Created by Subeen on 1/27/26.
//

import UIKit
import SnapKit
import Then
import Kingfisher

final class FeedItemCell: UICollectionViewCell {

    // MARK: - Properties

    private let thumbnailImageView = UIImageView()
    private let dimView = UIView()
    private let radioButton = UIImageView()

    // MARK: - Initialization

    override init(frame: CGRect) {
        super.init(frame: frame)
        style()
        layout()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Configuration

    func configure(feedItem: FeedItem, isSelectionMode: Bool, isSelected: Bool) {
        if let url = URL(string: feedItem.thumbnailImageUrl) {
            thumbnailImageView.kf.setImage(with: url)
        } else {
            thumbnailImageView.image = nil
            thumbnailImageView.backgroundColor = .systemGray5
        }

        // Selection mode가 아니면 dim 처리
        dimView.isHidden = isSelectionMode

        // Selection mode이고 선택된 경우 라디오 버튼 표시
        radioButton.isHidden = !isSelectionMode || !isSelected

        if isSelected {
            radioButton.image = UIImage(systemName: "checkmark.circle.fill")
            radioButton.tintColor = .systemOrange
        }
    }
}

// MARK: - Setup

extension FeedItemCell {
    private func style() {
        thumbnailImageView.do {
            $0.contentMode = .scaleAspectFill
            $0.clipsToBounds = true
            $0.backgroundColor = .systemGray6
        }

        dimView.do {
            $0.backgroundColor = .white.withAlphaComponent(0.7)
            $0.isHidden = false
        }

        radioButton.do {
            $0.contentMode = .scaleAspectFit
            $0.isHidden = true
        }
    }

    private func layout() {
        contentView.addSubview(thumbnailImageView)
        contentView.addSubview(dimView)
        contentView.addSubview(radioButton)

        thumbnailImageView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }

        dimView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }

        radioButton.snp.makeConstraints {
            $0.trailing.equalToSuperview().offset(-8)
            $0.bottom.equalToSuperview().offset(-8)
            $0.width.height.equalTo(24)
        }
    }
}
