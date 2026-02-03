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

    // MARK: - UI Components

    private let iconImageView = UIImageView()
    private let messageLabel = UILabel()
    private let actionButton = UIButton()

    // MARK: - Properties

    private var onAction: (() -> Void)?
    private var actionTitle: String?

    // MARK: - Initialization

    init(message: String, actionTitle: String? = nil, onAction: (() -> Void)? = nil) {
        self.onAction = onAction
        self.actionTitle = actionTitle
        super.init(frame: .zero)
        messageLabel.text = message

        if actionTitle != nil {
            actionButton.isHidden = false
        } else {
            actionButton.isHidden = true
        }

        style()
        layout()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? {
        // bounds 체크를 수동으로 수행
        if bounds.contains(point) {
            // 버튼 체크
            let buttonPoint = actionButton.convert(point, from: self)
            if actionButton.bounds.contains(buttonPoint) && !actionButton.isHidden {
                return actionButton
            }
            return self
        }
        return nil
    }

    // MARK: - Public Methods

    /// 화면 상단에 토스트 메시지 표시 (액션 버튼 없음)
    static func show(message: String, duration: TimeInterval = 2.0) {
        show(message: message, actionTitle: nil, duration: duration, onAction: nil)
    }

    /// 화면 상단에 토스트 메시지 표시 (액션 버튼 포함)
    static func show(
        message: String,
        actionTitle: String?,
        duration: TimeInterval = 3.0,
        onAction: (() -> Void)?
    ) {
        guard let window = UIApplication.shared.windows.first(where: { $0.isKeyWindow }) else {
            return
        }

        let toast = ToastView(message: message, actionTitle: actionTitle, onAction: onAction)
        window.addSubview(toast)

        toast.snp.makeConstraints {
            // safe area top + navigation bar height(44) + 10pt spacing
            $0.top.equalTo(window.safeAreaLayoutGuide.snp.top).offset(54)
            $0.leading.equalToSuperview().offset(20)
            $0.trailing.equalToSuperview().offset(-20)
            $0.height.greaterThanOrEqualTo(48)
        }

        window.bringSubviewToFront(toast)
        toast.alpha = 0

        // 페이드 인
        UIView.animate(withDuration: 0.3, delay: 0, options: [.curveEaseOut, .allowUserInteraction]) {
            toast.alpha = 1
        } completion: { _ in
            // 일정 시간 후 페이드 아웃
            UIView.animate(withDuration: 0.3, delay: duration, options: [.curveEaseIn, .allowUserInteraction]) {
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
        backgroundColor = UIColor.black.withAlphaComponent(0.68)
        layer.cornerRadius = 12
        clipsToBounds = true
        isUserInteractionEnabled = true

        iconImageView.do {
            $0.image = .Icon.checkCircle
            $0.contentMode = .scaleAspectFit
        }

        messageLabel.do {
            $0.textColor = .white
            $0.numberOfLines = 0
            $0.applyTypography(.header14)
        }

        actionButton.do {
            var config = UIButton.Configuration.plain()
            config.baseForegroundColor = .neutral100
            config.contentInsets = NSDirectionalEdgeInsets(top: 8, leading: 12, bottom: 8, trailing: 12)

            if let title = actionTitle {
                var attributedTitle = AttributedString(title)
                attributedTitle.font = TypographyStyle.label12.font
                config.attributedTitle = attributedTitle
            }

            $0.configuration = config
            $0.isUserInteractionEnabled = true
            $0.addTarget(self, action: #selector(actionButtonTapped), for: .touchUpInside)
        }
    }

    private func layout() {
        addSubview(iconImageView)
        addSubview(messageLabel)
        addSubview(actionButton)

        iconImageView.snp.makeConstraints {
            $0.leading.equalToSuperview().offset(20)
            $0.centerY.equalToSuperview()
            $0.width.height.equalTo(20)
        }

        if actionButton.isHidden {
            messageLabel.snp.makeConstraints {
                $0.leading.equalTo(iconImageView.snp.trailing).offset(8)
                $0.trailing.equalToSuperview().offset(-20)
                $0.top.equalToSuperview().offset(12)
                $0.bottom.equalToSuperview().offset(-12)
            }
        } else {
            messageLabel.snp.makeConstraints {
                $0.leading.equalTo(iconImageView.snp.trailing).offset(8)
                $0.top.equalToSuperview().offset(12)
                $0.bottom.equalToSuperview().offset(-12)
            }

            actionButton.snp.makeConstraints {
                $0.leading.equalTo(messageLabel.snp.trailing).offset(8)
                $0.trailing.equalToSuperview().offset(-20)
                $0.centerY.equalToSuperview()
            }

            // Set content hugging priority so message label expands and action button stays compact
            actionButton.setContentHuggingPriority(.required, for: .horizontal)
            actionButton.setContentCompressionResistancePriority(.required, for: .horizontal)
        }
    }

    @objc private func actionButtonTapped() {
        onAction?()

        // Dismiss toast immediately when action is tapped
        UIView.animate(withDuration: 0.2, delay: 0, options: .curveEaseIn) {
            self.transform = CGAffineTransform(translationX: 0, y: -100)
            self.alpha = 0
        } completion: { _ in
            self.removeFromSuperview()
        }
    }
}
