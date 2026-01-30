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

    private let dimmerView = UIView().then {
        $0.backgroundColor = UIColor.black.withAlphaComponent(0.5)
    }

    private let containerView = UIView().then {
        $0.backgroundColor = .white
        $0.layer.cornerRadius = 20
        $0.layer.shadowColor = UIColor.black.cgColor
        $0.layer.shadowOpacity = 0.12
        $0.layer.shadowOffset = CGSize(width: 0, height: 2)
        $0.layer.shadowRadius = 12
    }

    private let titleLabel = UILabel().then {
        $0.font = UIFont(name: "Pretendard-Bold", size: 18) ?? .systemFont(ofSize: 18, weight: .bold)
        $0.textColor = UIColor(hex: "#1e1e1e")
        $0.textAlignment = .left
        $0.numberOfLines = 1
    }

    private let messageLabel = UILabel().then {
        $0.font = UIFont(name: "Pretendard-Regular", size: 14) ?? .systemFont(ofSize: 14, weight: .regular)
        $0.textColor = UIColor(hex: "#3a3a3a")
        $0.textAlignment = .center
        $0.numberOfLines = 0
    }

    private lazy var cancelButton = UIButton().then {
        $0.backgroundColor = UIColor(hex: "#e5e5e5")
        $0.layer.cornerRadius = 40
        $0.setTitleColor(UIColor(hex: "#1e1e1e"), for: .normal)
        $0.titleLabel?.font = UIFont(name: "Pretendard-Bold", size: 14) ?? .systemFont(ofSize: 14, weight: .bold)
        $0.addTarget(self, action: #selector(cancelButtonTapped), for: .touchUpInside)
    }

    private lazy var confirmButton = UIButton().then {
        $0.backgroundColor = UIColor(hex: "#ff9447")
        $0.layer.cornerRadius = 40
        $0.setTitleColor(.white, for: .normal)
        $0.titleLabel?.font = UIFont(name: "Pretendard-Bold", size: 14) ?? .systemFont(ofSize: 14, weight: .bold)
        $0.addTarget(self, action: #selector(confirmButtonTapped), for: .touchUpInside)
    }

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
        setupUI()
        configure()
    }

    // MARK: - Setup

    private func setupUI() {
        view.backgroundColor = .clear

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
            $0.leading.equalToSuperview().offset(20)
            $0.trailing.equalToSuperview().offset(-20)
        }

        messageLabel.snp.makeConstraints {
            $0.top.equalTo(titleLabel.snp.bottom).offset(18)
            $0.leading.equalToSuperview().offset(20)
            $0.trailing.equalToSuperview().offset(-20)
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
        titleLabel.text = alertTitle
        messageLabel.text = message
        cancelButton.setTitle(cancelButtonTitle, for: .normal)
        confirmButton.setTitle(confirmButtonTitle, for: .normal)
    }

    // MARK: - Actions

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


