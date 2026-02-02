//
//  HobbyCoverCell.swift
//  Forday
//
//  Created by Subeen on 1/27/26.
//

import UIKit
import SnapKit
import Then
import Kingfisher

final class HobbyCoverCell: UICollectionViewCell {

    // MARK: - Properties

    private let containerView = UIView()
    private let coverImageView = UIImageView()
    private let cameraIconView = UIImageView()
    private let hobbyNameLabel = UILabel()
    private let dimView = UIView()

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

    func configure(hobby: MyPageHobby) {
        hobbyNameLabel.text = hobby.hobbyName

        if let coverImageUrl = hobby.thumbnailImageUrl, !coverImageUrl.isEmpty {
            coverImageView.kf.setImage(with: URL(string: coverImageUrl))
        } else {
            coverImageView.image = UIImage(systemName: "photo")
            coverImageView.tintColor = .systemGray3
        }

        // Archived 취미는 dim 처리
        dimView.isHidden = hobby.status != .archived
    }
}

// MARK: - Setup

extension HobbyCoverCell {
    private func style() {
        containerView.do {
            $0.backgroundColor = .clear
        }

        coverImageView.do {
            $0.contentMode = .scaleAspectFill
            $0.clipsToBounds = true
            $0.layer.cornerRadius = 36
            $0.backgroundColor = .systemGray6
        }

        cameraIconView.do {
            $0.image = UIImage(systemName: "camera.fill")
            $0.tintColor = .white
            $0.contentMode = .scaleAspectFit
            $0.backgroundColor = .black.withAlphaComponent(0.6)
            $0.layer.cornerRadius = 12
            $0.clipsToBounds = true
        }

        hobbyNameLabel.do {
            $0.font = .systemFont(ofSize: 12, weight: .medium)
            $0.textColor = .label
            $0.textAlignment = .center
            $0.numberOfLines = 1
        }

        dimView.do {
            $0.backgroundColor = .white.withAlphaComponent(0.7)
            $0.layer.cornerRadius = 36
            $0.isHidden = true
        }
    }

    private func layout() {
        contentView.addSubview(containerView)
        containerView.addSubview(coverImageView)
        containerView.addSubview(dimView)
        containerView.addSubview(cameraIconView)
        containerView.addSubview(hobbyNameLabel)

        containerView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }

        coverImageView.snp.makeConstraints {
            $0.top.equalToSuperview()
            $0.centerX.equalToSuperview()
            $0.width.height.equalTo(72)
        }

        dimView.snp.makeConstraints {
            $0.edges.equalTo(coverImageView)
        }

        cameraIconView.snp.makeConstraints {
            $0.trailing.equalTo(coverImageView.snp.trailing).offset(-2)
            $0.bottom.equalTo(coverImageView.snp.bottom).offset(-2)
            $0.width.height.equalTo(24)
        }

        hobbyNameLabel.snp.makeConstraints {
            $0.top.equalTo(coverImageView.snp.bottom).offset(8)
            $0.leading.trailing.equalToSuperview()
            $0.bottom.equalToSuperview()
        }
    }
}
