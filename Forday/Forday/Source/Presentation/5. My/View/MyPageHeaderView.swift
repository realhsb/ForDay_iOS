//
//  MyPageHeaderView.swift
//  Forday
//
//  Created by Subeen on 1/23/26.
//

import UIKit
import SnapKit
import Then

final class MyPageHeaderView: UIView {

    // MARK: - Properties

    private let profileImageView = UIImageView()
    private let nicknameLabel = UILabel()
    private let stickerCountLabel = UILabel()

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

    func configure(with profile: UserProfile) {
        nicknameLabel.text = profile.nickname
        stickerCountLabel.text = profile.stickerDisplayText

        // Profile image
        if let imageUrlString = profile.profileImageUrl,
           let imageUrl = URL(string: imageUrlString) {
            // TODO: Load image from URL when image loading is implemented
            profileImageView.image = UIImage(systemName: "person.circle.fill")
        } else {
            profileImageView.image = UIImage(systemName: "person.circle.fill")
        }
    }
}

// MARK: - Setup

extension MyPageHeaderView {
    private func style() {
        backgroundColor = .systemBackground

        profileImageView.do {
            $0.contentMode = .scaleAspectFill
            $0.clipsToBounds = true
            $0.layer.cornerRadius = 28
            $0.tintColor = .systemGray3
            $0.backgroundColor = .systemGray6
        }

        nicknameLabel.do {
            $0.font = .systemFont(ofSize: 20, weight: .bold)
            $0.textColor = .label
        }

        stickerCountLabel.do {
            $0.font = .systemFont(ofSize: 14, weight: .regular)
            $0.textColor = .secondaryLabel
        }
    }

    private func layout() {
        addSubview(profileImageView)
        addSubview(nicknameLabel)
        addSubview(stickerCountLabel)

        profileImageView.snp.makeConstraints {
            $0.leading.equalToSuperview().offset(20)
            $0.centerY.equalToSuperview()
            $0.width.height.equalTo(56)
        }

        nicknameLabel.snp.makeConstraints {
            $0.leading.equalTo(profileImageView.snp.trailing).offset(16)
            $0.trailing.equalToSuperview().offset(-20)
            $0.bottom.equalTo(profileImageView.snp.centerY).offset(-2)
        }

        stickerCountLabel.snp.makeConstraints {
            $0.leading.equalTo(nicknameLabel)
            $0.trailing.equalToSuperview().offset(-20)
            $0.top.equalTo(profileImageView.snp.centerY).offset(2)
        }
    }
}
