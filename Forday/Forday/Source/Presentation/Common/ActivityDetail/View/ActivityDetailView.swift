//
//  ActivityDetailView.swift
//  Forday
//
//  Created by Subeen on 1/23/26.
//

import UIKit
import SnapKit
import Then
import Kingfisher

final class ActivityDetailView: UIView {

    // MARK: - Properties

    private let scrollView = UIScrollView()
    private let contentStackView = UIStackView()

    let imageView = UIImageView()
    let stickerImageView = UIImageView()
    let dateLabel = UILabel()
    let titleLabel = UILabel()
    let contentLabel = UILabel()
    let reactionUsersScrollView = ReactionUsersScrollView()
    let reactionButtonsView = ReactionButtonsView()

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

    func configure(with detail: ActivityDetail) {
        // Load image from URL
        loadImage(from: detail.imageUrl)

        // Load sticker image
        if let stickerType = StickerType(fileName: detail.sticker) {
            stickerImageView.image = stickerType.image
        }

        dateLabel.text = detail.createdAt
        titleLabel.text = detail.activityContent

        // Show memo if available
        if detail.memo.isEmpty {
            contentLabel.text = "메모가 없습니다"
            contentLabel.textColor = .secondaryLabel
        } else {
            contentLabel.text = detail.memo
            contentLabel.textColor = .label
        }

        // Configure reaction buttons
        reactionButtonsView.configure(with: detail)
    }

    private func loadImage(from urlString: String) {
        guard !urlString.isEmpty, let url = URL(string: urlString) else {
            // Show placeholder if URL is invalid or empty
            imageView.image = UIImage(systemName: "photo.fill")
            imageView.tintColor = .systemGray3
            return
        }

        let placeholder = UIImage(systemName: "photo.fill")
        imageView.kf.setImage(
            with: url,
            placeholder: placeholder,
            options: [
                .transition(.fade(0.2)),
                .cacheOriginalImage
            ]
        )
    }
}

// MARK: - Setup

extension ActivityDetailView {
    private func style() {
        backgroundColor = .systemBackground

        scrollView.do {
            $0.showsVerticalScrollIndicator = true
        }

        contentStackView.do {
            $0.axis = .vertical
            $0.spacing = 16
            $0.alignment = .fill
            $0.distribution = .fill
        }

        imageView.do {
            $0.contentMode = .scaleAspectFill
            $0.clipsToBounds = true
            $0.backgroundColor = .systemGray5
        }

        stickerImageView.do {
            $0.contentMode = .scaleAspectFit
        }

        dateLabel.do {
            $0.font = .systemFont(ofSize: 14, weight: .regular)
            $0.textColor = .secondaryLabel
        }

        titleLabel.do {
            $0.font = .systemFont(ofSize: 20, weight: .bold)
            $0.textColor = .label
            $0.numberOfLines = 0
        }

        contentLabel.do {
            $0.font = .systemFont(ofSize: 16, weight: .regular)
            $0.textColor = .label
            $0.numberOfLines = 0
        }
    }

    private func layout() {
        addSubview(scrollView)
        scrollView.addSubview(contentStackView)

        scrollView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }

        contentStackView.snp.makeConstraints {
            $0.edges.equalToSuperview()
            $0.width.equalToSuperview()
        }

        // Add views to stack
        contentStackView.addArrangedSubview(imageView)
        contentStackView.addArrangedSubview(createInfoContainer())
        contentStackView.addArrangedSubview(reactionUsersScrollView)
        contentStackView.addArrangedSubview(reactionButtonsView)

        // Initially hide reaction users scroll view
        reactionUsersScrollView.isHidden = true
        reactionUsersScrollView.snp.makeConstraints {
            $0.height.equalTo(60)  // 28 (image) + 4 (spacing) + 12 (label) + 16 (padding)
        }

        // Add sticker overlay on image
        imageView.addSubview(stickerImageView)

        imageView.snp.makeConstraints {
            $0.height.equalTo(300)
        }

        stickerImageView.snp.makeConstraints {
            $0.trailing.equalToSuperview().offset(-21)
            $0.bottom.equalToSuperview().offset(-21)
            $0.size.equalTo(80)
        }
    }

    private func createInfoContainer() -> UIView {
        let container = UIView()

        container.addSubview(dateLabel)
        container.addSubview(titleLabel)
        container.addSubview(contentLabel)

        dateLabel.snp.makeConstraints {
            $0.top.equalToSuperview().offset(16)
            $0.leading.equalToSuperview().offset(20)
            $0.trailing.equalToSuperview().offset(-20)
        }

        titleLabel.snp.makeConstraints {
            $0.top.equalTo(dateLabel.snp.bottom).offset(8)
            $0.leading.equalToSuperview().offset(20)
            $0.trailing.equalToSuperview().offset(-20)
        }

        contentLabel.snp.makeConstraints {
            $0.top.equalTo(titleLabel.snp.bottom).offset(12)
            $0.leading.equalToSuperview().offset(20)
            $0.trailing.equalToSuperview().offset(-20)
            $0.bottom.equalToSuperview().offset(-16)
        }

        return container
    }
}
