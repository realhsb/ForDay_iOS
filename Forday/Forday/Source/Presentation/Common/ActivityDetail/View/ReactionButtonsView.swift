//
//  ReactionButtonsView.swift
//  Forday
//
//  Created by Subeen on 1/30/26.
//

import UIKit
import SnapKit
import Then
import Combine
import Kingfisher

final class ReactionButtonsView: UIView {

    // MARK: - UI Components

    private let profileImageView = UIImageView()
    private let awesomeButton = ReactionButton(type: .awesome)
    private let greatButton = ReactionButton(type: .great)
    private let amazingButton = ReactionButton(type: .amazing)
    private let bookmarkButton = UIButton()

    private let leftStackView = UIStackView()
    private let topBorder = UIView()

    // Tap events
    let reactionSingleTapped = PassthroughSubject<ReactionType, Never>()
    let reactionDoubleTapped = PassthroughSubject<ReactionType, Never>()
    let bookmarkTapped = PassthroughSubject<Void, Never>()

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

    func configure(with detail: ActivityDetail) {
        // Configure profile image
        if let userInfo = detail.userInfo, let imageUrl = userInfo.profileImageUrl, let url = URL(string: imageUrl) {
            profileImageView.kf.setImage(
                with: url,
                placeholder: UIImage(named: "Icon.profile"),
                options: [
                    .transition(.fade(0.2)),
                    .cacheOriginalImage
                ]
            )
        } else {
            profileImageView.image = UIImage(named: "Icon.profile")
        }

        // Configure reaction buttons
        awesomeButton.configure(
            isPressed: detail.userReaction.awesome,
            hasNewReaction: detail.newReaction.awesome
        )
        greatButton.configure(
            isPressed: detail.userReaction.great,
            hasNewReaction: detail.newReaction.great
        )
        amazingButton.configure(
            isPressed: detail.userReaction.amazing,
            hasNewReaction: detail.newReaction.amazing
        )

        // Configure bookmark button
        let bookmarkImage = detail.scraped ? UIImage(named: "Icon.bookmarkOn") : UIImage(named: "Icon.bookmarkOff")
        bookmarkButton.setImage(bookmarkImage, for: .normal)
    }
}

// MARK: - Setup

extension ReactionButtonsView {
    private func style() {
        backgroundColor = .systemBackground

        topBorder.do {
            $0.backgroundColor = UIColor(red: 229/255, green: 229/255, blue: 229/255, alpha: 1) // #E5E5E5
        }

        profileImageView.do {
            $0.contentMode = .scaleAspectFill
            $0.clipsToBounds = true
            $0.layer.cornerRadius = 20
            $0.backgroundColor = UIColor(red: 249/255, green: 249/255, blue: 249/255, alpha: 1) // #F9F9F9
        }

        leftStackView.do {
            $0.axis = .horizontal
            $0.spacing = 16
            $0.alignment = .center
            $0.distribution = .equalSpacing
        }

        bookmarkButton.do {
            $0.contentMode = .scaleAspectFit
            $0.tintColor = .label
        }
    }

    private func layout() {
        addSubview(topBorder)
        addSubview(leftStackView)
        addSubview(bookmarkButton)

        topBorder.snp.makeConstraints {
            $0.top.leading.trailing.equalToSuperview()
            $0.height.equalTo(1)
        }

        leftStackView.snp.makeConstraints {
            $0.top.equalToSuperview().offset(16)
            $0.leading.equalToSuperview().offset(20)
            $0.bottom.equalToSuperview().offset(-16)
            $0.height.equalTo(40)
        }

        bookmarkButton.snp.makeConstraints {
            $0.trailing.equalToSuperview().offset(-20)
            $0.centerY.equalTo(leftStackView)
            $0.size.equalTo(24)
        }

        // Add components to left stack
        [profileImageView, awesomeButton, greatButton, amazingButton].forEach {
            leftStackView.addArrangedSubview($0)
            $0.snp.makeConstraints { make in
                make.size.equalTo(40)
            }
        }
    }

    private func setupActions() {
        setupGestureRecognizers(for: awesomeButton, type: .awesome)
        setupGestureRecognizers(for: greatButton, type: .great)
        setupGestureRecognizers(for: amazingButton, type: .amazing)

        bookmarkButton.addTarget(self, action: #selector(bookmarkButtonTapped), for: .touchUpInside)
    }

    private func setupGestureRecognizers(for button: UIButton, type: ReactionType) {
        // Single tap
        let singleTap = UITapGestureRecognizer(target: self, action: #selector(handleSingleTap(_:)))
        singleTap.numberOfTapsRequired = 1

        // Double tap
        let doubleTap = UITapGestureRecognizer(target: self, action: #selector(handleDoubleTap(_:)))
        doubleTap.numberOfTapsRequired = 2

        // Single tap should wait for double tap to fail
        singleTap.require(toFail: doubleTap)

        // Store reaction type in gesture recognizer
        singleTap.name = type.rawValue
        doubleTap.name = type.rawValue

        button.addGestureRecognizer(singleTap)
        button.addGestureRecognizer(doubleTap)
        button.isUserInteractionEnabled = true
    }

    @objc private func handleSingleTap(_ gesture: UITapGestureRecognizer) {
        guard let typeName = gesture.name,
              let type = ReactionType(rawValue: typeName) else { return }
        reactionSingleTapped.send(type)
    }

    @objc private func handleDoubleTap(_ gesture: UITapGestureRecognizer) {
        guard let typeName = gesture.name,
              let type = ReactionType(rawValue: typeName) else { return }
        reactionDoubleTapped.send(type)
    }

    @objc private func bookmarkButtonTapped() {
        bookmarkTapped.send()
    }
}

// MARK: - Reaction Button

private final class ReactionButton: UIButton {

    private let reactionType: ReactionType
    private let iconImageView = UIImageView()
    private let newReactionDot = UIView()

    private var isPressed: Bool = false
    private var hasNewReaction: Bool = false

    init(type: ReactionType) {
        self.reactionType = type
        super.init(frame: .zero)
        setup()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setup() {
        // Background
        backgroundColor = UIColor(red: 249/255, green: 249/255, blue: 249/255, alpha: 1) // #F9F9F9
        layer.cornerRadius = 20
        clipsToBounds = false

        // Icon
        iconImageView.do {
            $0.contentMode = .scaleAspectFit
            $0.image = reactionType.icon
            $0.tintColor = UIColor(red: 255/255, green: 162/255, blue: 74/255, alpha: 1) // #FFA24A
            $0.isUserInteractionEnabled = false
        }

        addSubview(iconImageView)
        iconImageView.snp.makeConstraints {
            $0.center.equalToSuperview()
            $0.size.equalTo(22)
        }

        // New reaction dot
        newReactionDot.do {
            $0.backgroundColor = UIColor(red: 242/255, green: 95/255, blue: 89/255, alpha: 1) // #F25F59
            $0.layer.cornerRadius = 3
            $0.isHidden = true
        }

        addSubview(newReactionDot)
        newReactionDot.snp.makeConstraints {
            $0.trailing.equalToSuperview().offset(2)
            $0.top.equalToSuperview().offset(-2)
            $0.size.equalTo(6)
        }
    }

    func configure(isPressed: Bool, hasNewReaction: Bool) {
        self.isPressed = isPressed
        self.hasNewReaction = hasNewReaction

        updateAppearance()
    }

    private func updateAppearance() {
        // Border style
        if isPressed {
            layer.borderWidth = 2
            layer.borderColor = UIColor(red: 255/255, green: 162/255, blue: 74/255, alpha: 1).cgColor // #FFA24A
        } else {
            layer.borderWidth = 0
            layer.borderColor = nil
        }

        // New reaction dot
        newReactionDot.isHidden = !hasNewReaction
    }
}

// MARK: - ReactionType Icon

extension ReactionType {
    var icon: UIImage? {
        switch self {
        case .awesome:
            return UIImage(systemName: "star.fill")
        case .great:
            return UIImage(systemName: "hand.thumbsup.fill")
        case .amazing:
            return UIImage(systemName: "hands.clap.fill")
        case .fighting:
            return UIImage(systemName: "flame.fill")
        }
    }
}
