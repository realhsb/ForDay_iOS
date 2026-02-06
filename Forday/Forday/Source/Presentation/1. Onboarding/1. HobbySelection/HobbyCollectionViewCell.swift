//
//  HobbyCollectionViewCell.swift
//  Forday
//
//  Created by Subeen on 1/5/26.
//


import UIKit
import SnapKit
import Then

private class CellGradientView: UIView {
    override class var layerClass: AnyClass { CAGradientLayer.self }
    var gradientLayer: CAGradientLayer { layer as! CAGradientLayer }
}

class HobbyCollectionViewCell: UICollectionViewCell {

    static let identifier = "HobbyCollectionViewCell"

    // MARK: - UI Components

    private let backgroundImageView = UIImageView()
    private let gradientView = CellGradientView()
    private let titleLabel = UILabel()
    private let subtitleLabel = UILabel()
    private let checkmarkImageView = UIImageView()

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

    func configure(with hobby: HobbyCard, isSelected: Bool) {
        backgroundImageView.image = hobby.imageAsset.image
        titleLabel.setTextWithTypography(hobby.name, style: .body16)
        subtitleLabel.setTextWithTypography(hobby.description, style: .label12)
        subtitleLabel.textColor = .neutral50

        // Selected state
        if isSelected {
            contentView.layer.borderWidth = 2
            contentView.layer.borderColor = UIColor.action001.cgColor
            checkmarkImageView.image = .Onoff.checkboxTrue
        } else {
            contentView.layer.borderWidth = 1
            contentView.layer.borderColor = UIColor.stroke001.cgColor
            checkmarkImageView.image = .Onoff.checkboxFalse
        }
    }
}

// MARK: - Setup

extension HobbyCollectionViewCell {
    private func style() {
        contentView.do {
            $0.layer.cornerRadius = 16
            $0.clipsToBounds = true
            $0.layer.borderWidth = 1
            $0.layer.borderColor = UIColor.stroke001.cgColor
        }

        backgroundImageView.do {
            $0.contentMode = .scaleAspectFill
            $0.backgroundColor = .neutral100
        }

        gradientView.gradientLayer.do {
            $0.colors = [
                UIColor.clear.cgColor,
                UIColor.clear.cgColor,
                UIColor.black.withAlphaComponent(0.36).cgColor,
                UIColor.black.withAlphaComponent(0.6).cgColor
            ]
            $0.locations = [0.0, 0.50, 0.78, 1.0]
            $0.startPoint = CGPoint(x: 0.5, y: 0)
            $0.endPoint = CGPoint(x: 0.5, y: 1)
        }

        titleLabel.do {
            $0.textColor = .white
            $0.numberOfLines = 1
        }

        subtitleLabel.do {
            $0.textColor = .neutral50
            $0.numberOfLines = 2
        }

        checkmarkImageView.do {
            $0.image = .Onoff.checkboxFalse
            $0.contentMode = .scaleAspectFit
        }
    }

    private func layout() {
        contentView.addSubview(backgroundImageView)
        contentView.addSubview(gradientView)
        contentView.addSubview(titleLabel)
        contentView.addSubview(subtitleLabel)
        contentView.addSubview(checkmarkImageView)

        backgroundImageView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }

        gradientView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }

        checkmarkImageView.snp.makeConstraints {
            $0.top.equalToSuperview().offset(9)
            $0.trailing.equalToSuperview().offset(-11)
            $0.size.equalTo(22)
        }

        titleLabel.snp.makeConstraints {
            $0.leading.equalToSuperview().offset(9)
            $0.trailing.equalToSuperview().offset(-11)
            $0.bottom.equalTo(subtitleLabel.snp.top).offset(-4)
        }

        subtitleLabel.snp.makeConstraints {
            $0.leading.equalToSuperview().offset(9)
            $0.trailing.equalToSuperview().offset(-11)
            $0.bottom.equalToSuperview().offset(-12)
        }
    }
}
