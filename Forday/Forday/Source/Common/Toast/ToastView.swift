//
//  ToastView.swift
//  Forday
//
//  Created by Subeen on 1/27/26.
//

import UIKit
import SnapKit
import Then

final class ToastView: UIView {

    // MARK: - Properties

    private let iconImageView = UIImageView()
    private let messageLabel = UILabel()

    // MARK: - Initialization

    init(message: String) {
        super.init(frame: .zero)
        messageLabel.text = message
        style()
        layout()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Public Methods

    /// 화면 상단에 토스트 메시지 표시
    static func show(message: String, duration: TimeInterval = 2.0) {
        guard let window = UIApplication.shared.windows.first(where: { $0.isKeyWindow }) else {
            return
        }

        let toast = ToastView(message: message)
        window.addSubview(toast)

        toast.snp.makeConstraints {
            $0.top.equalTo(window.safeAreaLayoutGuide.snp.top).offset(16)
            $0.leading.equalToSuperview().offset(20)
            $0.trailing.equalToSuperview().offset(-20)
            $0.height.greaterThanOrEqualTo(56)
        }

        // 초기 위치: 화면 위로 숨김
        toast.transform = CGAffineTransform(translationX: 0, y: -100)
        toast.alpha = 0

        // 애니메이션: 슬라이드 인
        UIView.animate(withDuration: 0.3, delay: 0, options: .curveEaseOut) {
            toast.transform = .identity
            toast.alpha = 1
        } completion: { _ in
            // 일정 시간 후 슬라이드 아웃
            UIView.animate(withDuration: 0.3, delay: duration, options: .curveEaseIn) {
                toast.transform = CGAffineTransform(translationX: 0, y: -100)
                toast.alpha = 0
            } completion: { _ in
                toast.removeFromSuperview()
            }
        }
    }
}

// MARK: - Setup

extension ToastView {
    private func style() {
        backgroundColor = UIColor.black.withAlphaComponent(0.85)
        layer.cornerRadius = 12
        clipsToBounds = true

        iconImageView.do {
            $0.image = UIImage(systemName: "checkmark.circle.fill")
            $0.tintColor = .white
            $0.contentMode = .scaleAspectFit
        }

        messageLabel.do {
            $0.font = .systemFont(ofSize: 15, weight: .medium)
            $0.textColor = .white
            $0.numberOfLines = 0
        }
    }

    private func layout() {
        addSubview(iconImageView)
        addSubview(messageLabel)

        iconImageView.snp.makeConstraints {
            $0.leading.equalToSuperview().offset(16)
            $0.centerY.equalToSuperview()
            $0.width.height.equalTo(24)
        }

        messageLabel.snp.makeConstraints {
            $0.leading.equalTo(iconImageView.snp.trailing).offset(12)
            $0.trailing.equalToSuperview().offset(-16)
            $0.top.equalToSuperview().offset(16)
            $0.bottom.equalToSuperview().offset(-16)
        }
    }
}
