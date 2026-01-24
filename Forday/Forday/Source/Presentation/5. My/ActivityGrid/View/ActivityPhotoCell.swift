//
//  ActivityPhotoCell.swift
//  Forday
//
//  Created by Subeen on 1/23/26.
//

import UIKit
import SnapKit
import Then

final class ActivityPhotoCell: UICollectionViewCell {

    // MARK: - Properties

    static let identifier = "ActivityPhotoCell"

    private let imageView = UIImageView()
    private let stickerLabel = UILabel()

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
        imageView.image = nil
        stickerLabel.text = nil
    }

    // MARK: - Configuration

    func configure(with activity: MyPageActivity) {
        // TODO: Load image from URL when image loading is implemented
        // For now, use placeholder
        imageView.image = UIImage(systemName: "photo")
        imageView.tintColor = .systemGray3

        stickerLabel.text = activity.sticker
    }
}

// MARK: - Setup

extension ActivityPhotoCell {
    private func style() {
        contentView.backgroundColor = .systemGray6

        imageView.do {
            $0.contentMode = .scaleAspectFill
            $0.clipsToBounds = true
            $0.backgroundColor = .systemGray5
        }

        stickerLabel.do {
            $0.font = .systemFont(ofSize: 20)
            $0.textAlignment = .center
            $0.backgroundColor = UIColor.black.withAlphaComponent(0.3)
            $0.layer.cornerRadius = 15
            $0.clipsToBounds = true
        }
    }

    private func layout() {
        contentView.addSubview(imageView)
        contentView.addSubview(stickerLabel)

        imageView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }

        stickerLabel.snp.makeConstraints {
            $0.bottom.equalToSuperview().offset(-4)
            $0.trailing.equalToSuperview().offset(-4)
            $0.width.height.equalTo(30)
        }
    }
}
