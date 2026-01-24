//
//  SettingsMenuCell.swift
//  Forday
//
//  Created by Subeen on 1/23/26.
//

import UIKit
import SnapKit
import Then

final class SettingsMenuCell: UITableViewCell {

    // MARK: - Properties

    static let identifier = "SettingsMenuCell"

    private let titleLabel = UILabel()

    // MARK: - Initialization

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        styleCell()
        layoutCell()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Configuration

    func configure(with menuItem: SettingsMenuItem) {
        titleLabel.text = menuItem.title

        // Logout item should be red
        if case .logout = menuItem {
            titleLabel.textColor = .systemRed
        } else {
            titleLabel.textColor = .label
        }
    }
}

// MARK: - Setup

extension SettingsMenuCell {
    private func styleCell() {
        backgroundColor = .clear
        selectionStyle = .default

        titleLabel.do {
            $0.font = .systemFont(ofSize: 16, weight: .regular)
            $0.textColor = .label
        }
    }

    private func layoutCell() {
        contentView.addSubview(titleLabel)

        titleLabel.snp.makeConstraints {
            $0.leading.equalToSuperview().offset(16)
            $0.trailing.equalToSuperview().offset(-16)
            $0.centerY.equalToSuperview()
        }
    }
}
