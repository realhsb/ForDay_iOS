//
//  HobbySettingsCell.swift
//  Forday
//
//  Created by Subeen on 1/21/26.
//

import UIKit
import SnapKit
import Then

class HobbySettingsCell: UITableViewCell {

    static let identifier = "HobbySettingsCell"

    // UI Components
    private let containerView = UIView()
    private let hobbyIconView = UIImageView()
    private let hobbyNameLabel = UILabel()
    private let hobbyInfoLabel = UILabel()
    private let archiveButton = UIButton()
    private let actionStackView = UIStackView()
    private let timeButton = UIButton()
    private let executionButton = UIButton()
    private let goalDaysButton = UIButton()

    // Callbacks
    var onArchiveTapped: ((Int) -> Void)?
    var onUnarchiveTapped: ((Int) -> Void)?
    var onTimeEditTapped: ((Int) -> Void)?
    var onExecutionEditTapped: ((Int) -> Void)?
    var onGoalDaysEditTapped: ((Int) -> Void)?

    private var hobbyId: Int?
    private var isArchived: Bool = false

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupUI()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setupUI() {
        backgroundColor = .clear
        selectionStyle = .none

        // Container
        containerView.do {
            $0.backgroundColor = .systemBackground
            $0.layer.cornerRadius = 12
            $0.layer.shadowColor = UIColor.black.cgColor
            $0.layer.shadowOpacity = 0.05
            $0.layer.shadowOffset = CGSize(width: 0, height: 2)
            $0.layer.shadowRadius = 4
        }

        // Icon
        hobbyIconView.do {
            $0.contentMode = .scaleAspectFit
            $0.tintColor = .systemOrange
        }

        // Name
        hobbyNameLabel.do {
            $0.applyTypography(.header16)
            $0.textColor = .neutral900
        }

        // Info
        hobbyInfoLabel.do {
            $0.applyTypography(.body14)
            $0.textColor = .neutral500
        }

        // Archive button
        archiveButton.do {
            var config = UIButton.Configuration.plain()
            config.image = UIImage(systemName: "archivebox")
            config.imagePlacement = .leading
            config.imagePadding = 4
            config.baseForegroundColor = .neutral600
            config.contentInsets = NSDirectionalEdgeInsets(top: 8, leading: 12, bottom: 8, trailing: 12)
            $0.configuration = config
            $0.addTarget(self, action: #selector(archiveButtonTapped), for: .touchUpInside)
        }

        // Action Stack
        actionStackView.do {
            $0.axis = .horizontal
            $0.spacing = 8
            $0.distribution = .fillEqually
        }

        // Action Buttons
        configureActionButton(timeButton, title: "취미 시간 변경", action: #selector(timeButtonTapped))
        configureActionButton(executionButton, title: "실행 횟수 변경", action: #selector(executionButtonTapped))
        configureActionButton(goalDaysButton, title: "여정일 변경", action: #selector(goalDaysButtonTapped))

        actionStackView.addArrangedSubview(timeButton)
        actionStackView.addArrangedSubview(executionButton)
        actionStackView.addArrangedSubview(goalDaysButton)

        // Layout
        contentView.addSubview(containerView)
        containerView.addSubview(hobbyIconView)
        containerView.addSubview(hobbyNameLabel)
        containerView.addSubview(hobbyInfoLabel)
        containerView.addSubview(archiveButton)
        containerView.addSubview(actionStackView)

        containerView.snp.makeConstraints {
            $0.edges.equalToSuperview().inset(UIEdgeInsets(top: 8, left: 16, bottom: 8, right: 16))
        }

        hobbyIconView.snp.makeConstraints {
            $0.leading.equalToSuperview().offset(16)
            $0.top.equalToSuperview().offset(16)
            $0.width.height.equalTo(32)
        }

        hobbyNameLabel.snp.makeConstraints {
            $0.leading.equalTo(hobbyIconView.snp.trailing).offset(12)
            $0.top.equalTo(hobbyIconView.snp.top)
        }

        hobbyInfoLabel.snp.makeConstraints {
            $0.leading.equalTo(hobbyNameLabel)
            $0.top.equalTo(hobbyNameLabel.snp.bottom).offset(4)
        }

        archiveButton.snp.makeConstraints {
            $0.trailing.equalToSuperview().offset(-16)
            $0.top.equalToSuperview().offset(16)
        }

        actionStackView.snp.makeConstraints {
            $0.leading.equalToSuperview().offset(16)
            $0.trailing.equalToSuperview().offset(-16)
            $0.top.equalTo(hobbyInfoLabel.snp.bottom).offset(16)
            $0.bottom.equalToSuperview().offset(-16)
            $0.height.equalTo(36)
        }
    }

    private func configureActionButton(_ button: UIButton, title: String, action: Selector) {
        var config = UIButton.Configuration.plain()
        config.title = title
        config.baseForegroundColor = .neutral700
        config.background.backgroundColor = .systemGray6
        config.background.cornerRadius = 8
        config.contentInsets = NSDirectionalEdgeInsets(top: 8, leading: 12, bottom: 8, trailing: 12)

        button.configuration = config
        button.addTarget(self, action: action, for: .touchUpInside)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 13)
        button.titleLabel?.adjustsFontSizeToFitWidth = true
        button.titleLabel?.minimumScaleFactor = 0.8
    }

    @objc private func archiveButtonTapped() {
        guard let hobbyId = hobbyId else { return }
        if isArchived {
            onUnarchiveTapped?(hobbyId)
        } else {
            onArchiveTapped?(hobbyId)
        }
    }

    @objc private func timeButtonTapped() {
        guard let hobbyId = hobbyId else { return }
        onTimeEditTapped?(hobbyId)
    }

    @objc private func executionButtonTapped() {
        guard let hobbyId = hobbyId else { return }
        onExecutionEditTapped?(hobbyId)
    }

    @objc private func goalDaysButtonTapped() {
        guard let hobbyId = hobbyId else { return }
        onGoalDaysEditTapped?(hobbyId)
    }

    func configure(with hobby: HobbySetting, isArchived: Bool) {
        self.hobbyId = hobby.hobbyId
        self.isArchived = isArchived

        // Icon (default to book icon)
        hobbyIconView.image = UIImage(systemName: "book.fill")

        // Name & Info
        hobbyNameLabel.text = hobby.hobbyName
        hobbyInfoLabel.text = hobby.infoDisplayText

        // Archive button
        var config = archiveButton.configuration
        if isArchived {
            config?.title = "꺼내기"
            config?.image = UIImage(systemName: "tray.and.arrow.up")
        } else {
            config?.title = "보관"
            config?.image = UIImage(systemName: "archivebox")
        }
        archiveButton.configuration = config

        // Action buttons visibility
        actionStackView.isHidden = isArchived

        // Update goal days button text if needed
        if hobby.goalDays == nil {
            var goalConfig = goalDaysButton.configuration
            goalConfig?.title = "DAY 변경"
            goalDaysButton.configuration = goalConfig
        } else {
            var goalConfig = goalDaysButton.configuration
            goalConfig?.title = "여정일 변경"
            goalDaysButton.configuration = goalConfig
        }
    }
}
