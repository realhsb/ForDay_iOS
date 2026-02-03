//
//  OnboardingSlideCell.swift
//  Forday
//
//  Created by Subeen on 1/28/26.
//

import UIKit
import SnapKit
import Then

class OnboardingSlideCell: UICollectionViewCell {

    static let identifier = "OnboardingSlideCell"

    // Properties

    private let containerView = UIView()
    private let characterImageView = UIImageView()

    // Initialization

    override init(frame: CGRect) {
        super.init(frame: frame)
        style()
        layout()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // Configuration

    func configure(image: UIImage) {
        characterImageView.image = image

        // 그라데이션 배경 설정
        containerView.layer.sublayers?.removeAll(where: { $0 is CAGradientLayer })

        let gradientLayer = CAGradientLayer()
        gradientLayer.frame = containerView.bounds
//        gradientLayer.colors = gradientColors.map { $0.cgColor }
        gradientLayer.startPoint = CGPoint(x: 0, y: 0)
        gradientLayer.endPoint = CGPoint(x: 1, y: 1)

        containerView.layer.insertSublayer(gradientLayer, at: 0)
    }

    override func layoutSubviews() {
        super.layoutSubviews()

        // 그라데이션 레이어 크기 업데이트
        if let gradientLayer = containerView.layer.sublayers?.first(where: { $0 is CAGradientLayer }) as? CAGradientLayer {
            gradientLayer.frame = containerView.bounds
        }
    }
}

// Setup

extension OnboardingSlideCell {
    private func style() {
        containerView.do {
            $0.layer.cornerRadius = 20
            $0.layer.borderWidth = 1
            $0.layer.borderColor = UIColor.systemOrange.withAlphaComponent(0.2).cgColor
            $0.clipsToBounds = true
        }

        characterImageView.do {
            $0.contentMode = .scaleAspectFit
        }
    }

    private func layout() {
        contentView.addSubview(containerView)
        containerView.addSubview(characterImageView)

        containerView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }

        characterImageView.snp.makeConstraints {
            $0.edges.equalToSuperview().inset(16)
        }
    }
}
