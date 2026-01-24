//
//  EmptyStateView.swift
//  Forday
//
//  Created by Subeen on 1/23/26.
//

import UIKit
import SnapKit
import Then

final class EmptyStateView: UIView {

    // MARK: - Properties

    private let iconImageView = UIImageView()
    private let messageLabel = UILabel()
    private let actionButton = UIButton()

    var onActionTapped: (() -> Void)?

    // MARK: - Initialization

    override init(frame: CGRect) {
        super.init(frame: frame)
        style()
        layout()
        setupActions()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Configuration

    func configure(icon: UIImage?, message: String, actionTitle: String? = nil) {
        iconImageView.image = icon
        messageLabel.text = message

        if let actionTitle = actionTitle {
            actionButton.setTitle(actionTitle, for: .normal)
            actionButton.isHidden = false
        } else {
            actionButton.isHidden = true
        }
    }
}

// MARK: - Setup

extension EmptyStateView {
    private func style() {
        backgroundColor = .systemBackground

        iconImageView.do {
            $0.contentMode = .scaleAspectFit
            $0.tintColor = .systemGray3
        }

        messageLabel.do {
            $0.font = .systemFont(ofSize: 16, weight: .regular)
            $0.textColor = .secondaryLabel
            $0.textAlignment = .center
            $0.numberOfLines = 0
        }

        actionButton.do {
            var config = UIButton.Configuration.filled()
            config.cornerStyle = .medium
            config.baseBackgroundColor = .systemBlue
            config.baseForegroundColor = .white
            $0.configuration = config
            $0.isHidden = true
        }
    }

    private func layout() {
        addSubview(iconImageView)
        addSubview(messageLabel)
        addSubview(actionButton)

        iconImageView.snp.makeConstraints {
            $0.centerX.equalToSuperview()
            $0.centerY.equalToSuperview().offset(-60)
            $0.width.height.equalTo(80)
        }

        messageLabel.snp.makeConstraints {
            $0.top.equalTo(iconImageView.snp.bottom).offset(16)
            $0.leading.equalToSuperview().offset(40)
            $0.trailing.equalToSuperview().offset(-40)
        }

        actionButton.snp.makeConstraints {
            $0.top.equalTo(messageLabel.snp.bottom).offset(24)
            $0.centerX.equalToSuperview()
            $0.width.equalTo(160)
            $0.height.equalTo(44)
        }
    }

    private func setupActions() {
        actionButton.addTarget(self, action: #selector(actionButtonTapped), for: .touchUpInside)
    }
}

// MARK: - Actions

extension EmptyStateView {
    @objc private func actionButtonTapped() {
        onActionTapped?()
    }
}
