//
//  HobbyFilterCell.swift
//  Forday
//
//  Created by Subeen on 1/23/26.
//

import UIKit
import SnapKit
import Then
import Kingfisher

final class HobbyFilterCell: UICollectionViewCell {

    // MARK: - Properties

    static let identifier = "HobbyFilterCell"

    private let iconContainerView = UIView()
    private let iconImageView = UIImageView()
    private let nameLabel = UILabel()
    private let selectionBorderView = UIView()

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

    func configure(with hobby: MyPageHobby, isSelected: Bool) {
        // TODO: Load image from thumbnailImageUrl using Kingfisher
        // For now, use placeholder
        
        if let thumbnailImageUrl = hobby.thumbnailImageUrl {
            iconImageView.kf.setImage(
                  with: URL(string: thumbnailImageUrl),
                  placeholder: UIImage(systemName: "photo")
              )
        } else {
            iconImageView.image = UIImage(systemName: "photo")
        }
        
        
        iconImageView.tintColor = .label
        nameLabel.text = hobby.hobbyName

        // Apply dim for archived hobbies
        let alpha: CGFloat = hobby.status == .archived ? 0.4 : 1.0
        iconImageView.alpha = alpha
        nameLabel.alpha = alpha

        // Show selection border
        selectionBorderView.isHidden = !isSelected
    }

    func configureAsAll(isSelected: Bool) {
        iconImageView.image = UIImage(systemName: "square.grid.2x2")
        iconImageView.tintColor = .label
        nameLabel.text = "전체"

        iconImageView.alpha = 1.0
        nameLabel.alpha = 1.0

        selectionBorderView.isHidden = !isSelected
    }
}

// MARK: - Setup

extension HobbyFilterCell {
    private func style() {
        contentView.backgroundColor = .clear

        iconContainerView.do {
            $0.backgroundColor = .systemGray6
            $0.layer.cornerRadius = 28
            $0.clipsToBounds = true
        }

        iconImageView.do {
            $0.contentMode = .scaleAspectFit
            $0.tintColor = .label
        }

        nameLabel.do {
            $0.font = .systemFont(ofSize: 12, weight: .regular)
            $0.textColor = .label
            $0.textAlignment = .center
        }

        selectionBorderView.do {
            $0.layer.cornerRadius = 28
            $0.layer.borderWidth = 2
            $0.layer.borderColor = UIColor.label.cgColor
            $0.backgroundColor = .clear
            $0.isHidden = true
        }
    }

    private func layout() {
        contentView.addSubview(iconContainerView)
        iconContainerView.addSubview(iconImageView)
        contentView.addSubview(selectionBorderView)
        contentView.addSubview(nameLabel)

        iconContainerView.snp.makeConstraints {
            $0.top.equalToSuperview()
            $0.centerX.equalToSuperview()
            $0.width.height.equalTo(56)
        }

        iconImageView.snp.makeConstraints {
            $0.center.equalToSuperview()
            $0.width.height.equalTo(32)
        }

        selectionBorderView.snp.makeConstraints {
            $0.edges.equalTo(iconContainerView)
        }

        nameLabel.snp.makeConstraints {
            $0.top.equalTo(iconContainerView.snp.bottom).offset(4)
            $0.leading.trailing.equalToSuperview()
            $0.bottom.lessThanOrEqualToSuperview()
        }
    }
}
