//
//  CommonAlertViewController.swift
//  Forday
//
//  Created by Subeen on 1/29/26.
//

import UIKit
import SnapKit
import Then

final class CommonAlertViewController: UIViewController {

    // MARK: - Properties

    private let alertTitle: String
    private let message: String
    private let cancelButtonTitle: String
    private let confirmButtonTitle: String
    private let onCancel: (() -> Void)?
    private let onConfirm: () -> Void

    // MARK: - UI Components

    private let dimmerView = UIView()
    private let containerView = UIView()
    private let titleLabel = UILabel()
    private let messageLabel = UILabel()
    private lazy var cancelButton = UIButton()
    private lazy var confirmButton = UIButton()

    // MARK: - Initialization

    init(
        title: String,
        message: String,
        cancelButtonTitle: String = "취소",
        confirmButtonTitle: String = "확인",
        onCancel: (() -> Void)? = nil,
        onConfirm: @escaping () -> Void
    ) {
        self.alertTitle = title
        self.message = message
        self.cancelButtonTitle = cancelButtonTitle
        self.confirmButtonTitle = confirmButtonTitle
        self.onCancel = onCancel
        self.onConfirm = onConfirm
        super.init(nibName: nil, bundle: nil)

        modalPresentationStyle = .overFullScreen
        modalTransitionStyle = .crossDissolve
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        style()
        layout()
        configure()
    }
}

// MARK: - Setup

extension CommonAlertViewController {
    private func style() {
        view.backgroundColor = .clear

        dimmerView.do {
            $0.backgroundColor = UIColor.black.withAlphaComponent(0.5)
        }

        containerView.do {
            $0.backgroundColor = .neutralWhite
            $0.layer.cornerRadius = 20
            $0.layer.shadowColor = UIColor.black.cgColor
            $0.layer.shadowOpacity = 0.12
            $0.layer.shadowOffset = CGSize(width: 0, height: 2)
            $0.layer.shadowRadius = 12
        }

        titleLabel.do {
            $0.textColor = .neutral900
            $0.textAlignment = .left
            $0.numberOfLines = 0
        }

        messageLabel.do {
            $0.textColor = .neutral800
            $0.textAlignment = .center
            $0.numberOfLines = 0
        }

        cancelButton.do {
            $0.backgroundColor = .action003
            $0.layer.cornerRadius = 20
            $0.setTitleColor(.neutral900, for: .normal)
            $0.addTarget(self, action: #selector(cancelButtonTapped), for: .touchUpInside)
        }

        confirmButton.do {
            $0.backgroundColor = .action001
            $0.layer.cornerRadius = 20
            $0.setTitleColor(.neutralWhite, for: .normal)
            $0.addTarget(self, action: #selector(confirmButtonTapped), for: .touchUpInside)
        }
    }

    private func layout() {
        view.addSubview(dimmerView)
        view.addSubview(containerView)

        containerView.addSubview(titleLabel)
        containerView.addSubview(messageLabel)
        containerView.addSubview(cancelButton)
        containerView.addSubview(confirmButton)

        dimmerView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }

        containerView.snp.makeConstraints {
            $0.center.equalToSuperview()
            $0.width.equalTo(312)
        }

        titleLabel.snp.makeConstraints {
            $0.top.equalToSuperview().offset(24)
            $0.leading.trailing.equalToSuperview().inset(20)
        }

        messageLabel.snp.makeConstraints {
            $0.top.equalTo(titleLabel.snp.bottom).offset(10)
            $0.leading.trailing.equalToSuperview().inset(20)
        }

        cancelButton.snp.makeConstraints {
            $0.top.equalTo(messageLabel.snp.bottom).offset(20)
            $0.leading.equalToSuperview().offset(20)
            $0.height.equalTo(40)
            $0.bottom.equalToSuperview().offset(-24)
        }

        confirmButton.snp.makeConstraints {
            $0.top.equalTo(cancelButton)
            $0.leading.equalTo(cancelButton.snp.trailing).offset(20)
            $0.trailing.equalToSuperview().offset(-20)
            $0.height.equalTo(40)
            $0.width.equalTo(cancelButton)
        }
    }

    private func configure() {
        titleLabel.setTextWithTypography(alertTitle, style: .header18)
        messageLabel.setTextWithTypography(message, style: .label14)
        cancelButton.setTitle(cancelButtonTitle, for: .normal)
        cancelButton.applyTypography(.header14)
        confirmButton.setTitle(confirmButtonTitle, for: .normal)
        confirmButton.applyTypography(.header14)
    }
}

// MARK: - Actions

extension CommonAlertViewController {
    @objc private func cancelButtonTapped() {
        dismiss(animated: true) { [weak self] in
            self?.onCancel?()
        }
    }

    @objc private func confirmButtonTapped() {
        dismiss(animated: true) { [weak self] in
            self?.onConfirm()
        }
    }
}


