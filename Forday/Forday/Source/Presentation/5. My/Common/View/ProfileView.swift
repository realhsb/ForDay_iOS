//
//  ProfileView.swift
//  Forday
//
//  Created by Subeen on 1/23/26.
//

import UIKit
import SnapKit
import Then

final class ProfileView: UIView {

    // MARK: - UI Components

    private let navigationView = UIView()
    private let titleLabel = UILabel()
    let notificationButton = UIButton()
    let settingsButton = UIButton()

    let scrollView = UIScrollView()
    let refreshControl = UIRefreshControl()
    private let scrollContentView = UIView()

    let headerView = ProfileHeaderView()
    let segmentedControlView = ProfileSegmentedControlView()
    let contentContainerView = UIView()

    // MARK: - Initialization

    override init(frame: CGRect) {
        super.init(frame: frame)
        style()
        layout()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Public Methods

    func updateNotificationIcon(hasNotification: Bool) {
        let icon: UIImage? = hasNotification ? .Icon.notificationOn : .Icon.notificationOff
        notificationButton.setImage(icon, for: .normal)
    }
}

// MARK: - Setup

extension ProfileView {
    private func style() {
        backgroundColor = .systemBackground

        navigationView.do {
            $0.backgroundColor = .systemBackground
        }

        titleLabel.do {
            $0.setTextWithTypography("마이페이지", style: .header22)
            $0.textColor = .neutral900
        }

        notificationButton.do {
            $0.setImage(.Icon.notificationOff, for: .normal)
            $0.tintColor = .neutral900
        }

        settingsButton.do {
            $0.setImage(.Icon.settings, for: .normal)
            $0.tintColor = .neutral900
        }

        scrollView.do {
            $0.showsVerticalScrollIndicator = false
            $0.refreshControl = refreshControl
            $0.alwaysBounceVertical = true
        }

        scrollContentView.do {
            $0.backgroundColor = .systemBackground
        }

        contentContainerView.do {
            $0.backgroundColor = .systemBackground
        }
    }

    private func layout() {
        addSubview(navigationView)
        navigationView.addSubview(titleLabel)
        navigationView.addSubview(settingsButton)
        navigationView.addSubview(notificationButton)

        addSubview(scrollView)
        scrollView.addSubview(scrollContentView)

        scrollContentView.addSubview(headerView)
        scrollContentView.addSubview(segmentedControlView)
        scrollContentView.addSubview(contentContainerView)

        navigationView.snp.makeConstraints {
            $0.top.equalTo(safeAreaLayoutGuide)
            $0.leading.trailing.equalToSuperview()
            $0.height.equalTo(56)
        }

        titleLabel.snp.makeConstraints {
            $0.leading.equalToSuperview().offset(20)
            $0.centerY.equalToSuperview()
        }

        settingsButton.snp.makeConstraints {
            $0.trailing.equalToSuperview().offset(-20)
            $0.centerY.equalToSuperview()
            $0.width.height.equalTo(24)
        }

        notificationButton.snp.makeConstraints {
            $0.trailing.equalTo(settingsButton.snp.leading).offset(-16)
            $0.centerY.equalToSuperview()
            $0.width.height.equalTo(24)
        }

        scrollView.snp.makeConstraints {
            $0.top.equalTo(navigationView.snp.bottom)
            $0.leading.trailing.equalToSuperview()
            $0.bottom.equalTo(safeAreaLayoutGuide)
        }

        scrollContentView.snp.makeConstraints {
            $0.edges.equalToSuperview()
            $0.width.equalToSuperview()
        }

        headerView.snp.makeConstraints {
            $0.top.equalToSuperview()
            $0.leading.trailing.equalToSuperview()
            $0.height.equalTo(80)
        }

        segmentedControlView.snp.makeConstraints {
            $0.top.equalTo(headerView.snp.bottom)
            $0.leading.trailing.equalToSuperview()
            $0.height.equalTo(44)
        }

        contentContainerView.snp.makeConstraints {
            $0.top.equalTo(segmentedControlView.snp.bottom)
            $0.leading.trailing.equalToSuperview()
            $0.bottom.equalToSuperview()
            // 최소 높이 설정 - 화면 나머지 공간 채우기
            $0.height.greaterThanOrEqualTo(400)
        }
    }
}

#if DEBUG
#Preview {
    ProfileView()
}
#endif
