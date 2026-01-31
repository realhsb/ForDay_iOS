//
//  ActivityPhotoCell.swift
//  Forday
//
//  Created by Subeen on 1/23/26.
//

import UIKit
import SnapKit
import Then
import Kingfisher

final class ActivityPhotoCell: UICollectionViewCell {

    // MARK: - Properties

    static let identifier = "ActivityPhotoCell"

    // Image mode views
    private let imageView = UIImageView()

    // Gradient mode views
    private let gradientContainerView = UIView()
    private let quoteIconImageView = UIImageView()
    private let memoLabel = UILabel()

    // Shared sticker image view
    private let stickerImageView = UIImageView()
    private let stickerBackgroundView = UIView()

    // MARK: - Initialization

    override init(frame: CGRect) {
        super.init(frame: frame)
        style()
        layout()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Lifecycle

    override func prepareForReuse() {
        super.prepareForReuse()
        imageView.kf.cancelDownloadTask()
        imageView.image = nil
        stickerImageView.image = nil
        memoLabel.text = nil

        // Remove gradient layers
        gradientContainerView.layer.sublayers?.removeAll(where: { $0 is CAGradientLayer })
    }

    // MARK: - Configuration

    func configure(with activity: FeedItem) {
        // Display sticker image
        if let stickerType = activity.stickerType {
            stickerImageView.image = stickerType.image
        }

        // Branch based on thumbnailImageUrl
        if !activity.thumbnailImageUrl.isEmpty {
            // Image mode: Show image
            showImageMode(imageUrl: activity.thumbnailImageUrl)
        } else {
            // Gradient mode: Show gradient + memo
            showGradientMode(
                memo: activity.memo,
                stickerType: activity.stickerType
            )
        }
    }

    private func showImageMode(imageUrl: String) {
        // Show image view, hide gradient views
        imageView.isHidden = false
        gradientContainerView.isHidden = true

        // Load image
        guard let url = URL(string: imageUrl) else {
            imageView.image = UIImage(systemName: "photo")
            imageView.tintColor = .systemGray3
            return
        }

        let placeholder = UIImage(systemName: "photo")
        imageView.kf.setImage(
            with: url,
            placeholder: placeholder,
            options: [
                .transition(.fade(0.2)),
                .cacheOriginalImage
            ]
        )
    }

    private func showGradientMode(memo: String?, stickerType: StickerType?) {
        // Hide image view, show gradient views
        imageView.isHidden = true
        gradientContainerView.isHidden = false

        // Apply gradient background
        if let stickerType = stickerType {
            gradientContainerView.applyGradient(stickerType.gradient)
        } else {
            // Fallback to default gradient if sticker type unknown
            gradientContainerView.applyGradient(DesignGradient.gradient001)
        }

        // Set memo text (max 2 lines)
        memoLabel.text = memo ?? ""
    }
}

// MARK: - Setup

extension ActivityPhotoCell {
    private func style() {
        contentView.backgroundColor = .systemGray6
        contentView.clipsToBounds = true

        imageView.do {
            $0.contentMode = .scaleAspectFill
            $0.clipsToBounds = true
            $0.backgroundColor = .systemGray5
        }

        gradientContainerView.do {
            $0.isHidden = true
        }

        quoteIconImageView.do {
            $0.image = UIImage(systemName: "quote.opening")
            $0.tintColor = .white.withAlphaComponent(0.6)
            $0.contentMode = .scaleAspectFit
        }

        memoLabel.do {
            $0.font = .systemFont(ofSize: 13, weight: .medium)
            $0.textColor = .white
            $0.textAlignment = .left
            $0.numberOfLines = 2
            $0.lineBreakMode = .byTruncatingTail
        }

        stickerBackgroundView.do {
            $0.backgroundColor = UIColor.black.withAlphaComponent(0.3)
            $0.clipsToBounds = true
        }

        stickerImageView.do {
            $0.contentMode = .scaleAspectFit
        }
    }

    private func layout() {
        // Image view (for image mode)
        contentView.addSubview(imageView)

        // Gradient container (for gradient mode)
        contentView.addSubview(gradientContainerView)
        gradientContainerView.addSubview(quoteIconImageView)
        gradientContainerView.addSubview(memoLabel)

        // Sticker (shared) - background view and image view
        contentView.addSubview(stickerBackgroundView)
        stickerBackgroundView.addSubview(stickerImageView)

        // Image view layout
        imageView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }

        // Gradient container layout
        gradientContainerView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }

        // Quote icon layout
        quoteIconImageView.snp.makeConstraints {
            $0.top.equalToSuperview().offset(12)
            $0.leading.equalToSuperview().offset(12)
            $0.width.height.equalTo(16)
        }

        // Memo label layout
        memoLabel.snp.makeConstraints {
            $0.top.equalTo(quoteIconImageView.snp.bottom).offset(6)
            $0.leading.equalToSuperview().offset(12)
            $0.trailing.equalToSuperview().offset(-12)
        }

        // Sticker background layout (bottom-right)
        stickerBackgroundView.snp.makeConstraints {
            $0.bottom.equalToSuperview().offset(-4)
            $0.trailing.equalToSuperview().offset(-4)
            $0.width.height.equalTo(30)
        }

        // Sticker image layout (centered in background)
        stickerImageView.snp.makeConstraints {
            $0.center.equalToSuperview()
            $0.width.height.equalTo(20)
        }
    }
}
