//
//  SettingsDropdownView.swift
//  Forday
//
//  Created by Subeen on 1/23/26.
//

import UIKit
import SnapKit
import Then

enum SettingsMenuItem {
    case profileSettings
    case hobbyPhotoManagement
    case generalSettings
    case logout

    var title: String {
        switch self {
        case .profileSettings:
            return "내 프로필 설정"
        case .hobbyPhotoManagement:
            return "취미 대표사진 관리"
        case .generalSettings:
            return "전체설정"
        case .logout:
            return "로그아웃"
        }
    }
}

final class SettingsDropdownView: UIView {

    // MARK: - Properties

    private let tableView = UITableView()
    private let menuItems: [SettingsMenuItem] = [
        .profileSettings,
        .hobbyPhotoManagement,
        .generalSettings,
        .logout
    ]

    var onMenuSelected: ((SettingsMenuItem) -> Void)?

    // MARK: - Initialization

    override init(frame: CGRect) {
        super.init(frame: frame)
        style()
        layout()
        setupTableView()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Public Methods

    func show(in parentView: UIView, below sourceButton: UIBarButtonItem, navigationBar: UINavigationBar) {
        parentView.addSubview(self)

        let rowHeight: CGFloat = 48
        let totalHeight = CGFloat(menuItems.count) * rowHeight

        // Position relative to navigation bar
        self.snp.makeConstraints {
            $0.top.equalTo(navigationBar.snp.bottom).offset(8)
            $0.trailing.equalToSuperview().offset(-16)
            $0.width.equalTo(200)
            $0.height.equalTo(totalHeight)
        }

        // Fade in animation
        alpha = 0
        transform = CGAffineTransform(scaleX: 0.95, y: 0.95)

        UIView.animate(withDuration: 0.2, delay: 0, options: .curveEaseOut) {
            self.alpha = 1
            self.transform = .identity
        }
    }

    func dismiss() {
        UIView.animate(withDuration: 0.15, delay: 0, options: .curveEaseIn, animations: {
            self.alpha = 0
            self.transform = CGAffineTransform(scaleX: 0.95, y: 0.95)
        }) { _ in
            self.removeFromSuperview()
        }
    }
}

// MARK: - Setup

extension SettingsDropdownView {
    private func style() {
        backgroundColor = .systemBackground
        layer.cornerRadius = 12
        layer.shadowColor = UIColor.black.cgColor
        layer.shadowOpacity = 0.12
        layer.shadowOffset = CGSize(width: 0, height: 2)
        layer.shadowRadius = 12

        tableView.do {
            $0.backgroundColor = .clear
            $0.separatorStyle = .none
            $0.isScrollEnabled = false
        }
    }

    private func layout() {
        addSubview(tableView)

        tableView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
    }

    private func setupTableView() {
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(
            SettingsMenuCell.self,
            forCellReuseIdentifier: SettingsMenuCell.identifier
        )
    }
}

// MARK: - UITableViewDataSource

extension SettingsDropdownView: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return menuItems.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(
            withIdentifier: SettingsMenuCell.identifier,
            for: indexPath
        ) as? SettingsMenuCell else {
            return UITableViewCell()
        }

        let menuItem = menuItems[indexPath.row]
        cell.configure(with: menuItem)

        return cell
    }
}

// MARK: - UITableViewDelegate

extension SettingsDropdownView: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)

        let menuItem = menuItems[indexPath.row]
        onMenuSelected?(menuItem)

        dismiss()
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 48
    }
}
