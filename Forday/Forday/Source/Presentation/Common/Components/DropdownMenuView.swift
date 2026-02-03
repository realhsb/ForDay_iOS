//
//  DropdownMenuView.swift
//  Forday
//
//  Created by Subeen on 2/3/26.
//

import UIKit
import SnapKit
import Then

// MARK: - DropdownMenuItem Protocol

protocol DropdownMenuItem {
    var title: String { get }
    var textColor: UIColor { get }
}

extension DropdownMenuItem {
    var textColor: UIColor { .neutral800 }
}

// MARK: - DropdownMenuView

final class DropdownMenuView<Item: DropdownMenuItem>: UIView {

    // MARK: - Properties

    private let containerView = UIView()
    private let stackView = UIStackView()
    private let items: [Item]

    var onItemSelected: ((Item) -> Void)?

    // MARK: - Initialization

    init(items: [Item]) {
        self.items = items
        super.init(frame: .zero)
        style()
        layout()
        setupMenuItems()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

// MARK: - Setup

extension DropdownMenuView {
    private func style() {
        alpha = 0
        transform = CGAffineTransform(scaleX: 0.95, y: 0.95)
        isHidden = true

        containerView.do {
            $0.backgroundColor = .bg001
            $0.layer.cornerRadius = 12
            $0.layer.shadowColor = UIColor.black.cgColor
            $0.layer.shadowOpacity = 0.12
            $0.layer.shadowOffset = CGSize(width: 0, height: 2)
            $0.layer.shadowRadius = 12
        }

        stackView.do {
            $0.axis = .vertical
            $0.spacing = 0
            $0.alignment = .fill
        }
    }

    private func layout() {
        addSubview(containerView)
        containerView.addSubview(stackView)

        containerView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }

        stackView.snp.makeConstraints {
            $0.verticalEdges.equalToSuperview().inset(10)
            $0.horizontalEdges.equalToSuperview().inset(16)
        }
    }

    private func setupMenuItems() {
        for item in items {
            let menuItemView = DropdownMenuItemView(item: item)
            menuItemView.onTap = { [weak self] in
                self?.onItemSelected?(item)
            }
            stackView.addArrangedSubview(menuItemView)
        }
    }
}

// MARK: - Public Methods

extension DropdownMenuView {
    /// parentView에 추가하고 sourceView 아래에 표시
    func showInParent(_ parentView: UIView, below sourceView: UIView, width: CGFloat = 200) {
        isHidden = false
        parentView.addSubview(self)

        let itemHeight: CGFloat = 40
        let verticalPadding: CGFloat = 20 // 10px top + 10px bottom
        let totalHeight = CGFloat(items.count) * itemHeight + verticalPadding

        self.snp.makeConstraints {
            $0.top.equalTo(sourceView.snp.bottom).offset(8)
            $0.trailing.equalTo(sourceView)
            $0.width.equalTo(width)
            $0.height.equalTo(totalHeight)
        }

        alpha = 0
        transform = CGAffineTransform(scaleX: 0.95, y: 0.95)

        UIView.animate(withDuration: 0.2, delay: 0, options: .curveEaseOut) {
            self.alpha = 1
            self.transform = .identity
        }
    }

    /// navigationBar 아래에 표시
    func showInParent(_ parentView: UIView, belowNavigationBar navigationBar: UINavigationBar, trailingOffset: CGFloat = 16, width: CGFloat = 200) {
        isHidden = false
        parentView.addSubview(self)

        let itemHeight: CGFloat = 40
        let verticalPadding: CGFloat = 20 // 10px top + 10px bottom
        let totalHeight = CGFloat(items.count) * itemHeight + verticalPadding

        self.snp.makeConstraints {
            $0.top.equalTo(navigationBar.snp.bottom).offset(8)
            $0.trailing.equalToSuperview().offset(-trailingOffset)
            $0.width.equalTo(width)
            $0.height.equalTo(totalHeight)
        }

        alpha = 0
        transform = CGAffineTransform(scaleX: 0.95, y: 0.95)

        UIView.animate(withDuration: 0.2, delay: 0, options: .curveEaseOut) {
            self.alpha = 1
            self.transform = .identity
        }
    }

    /// 드롭다운 닫기
    func dismiss() {
        UIView.animate(withDuration: 0.15, delay: 0, options: .curveEaseIn, animations: {
            self.alpha = 0
            self.transform = CGAffineTransform(scaleX: 0.95, y: 0.95)
        }) { _ in
            self.removeFromSuperview()
        }
    }
}

// MARK: - DropdownMenuItemView

private final class DropdownMenuItemView<Item: DropdownMenuItem>: UIView {

    // MARK: - Properties

    private let titleLabel = UILabel()
    private let item: Item

    var onTap: (() -> Void)?

    // MARK: - Initialization

    init(item: Item) {
        self.item = item
        super.init(frame: .zero)
        style()
        layout()
        setupGesture()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Gesture (must be in main class body for generic classes)

    private func setupGesture() {
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(handleTap))
        addGestureRecognizer(tapGesture)
    }

    @objc private func handleTap() {
        // 탭 피드백 애니메이션
        UIView.animate(
            withDuration: 0.1,
            animations: { [weak self] in
                self?.alpha = 0.6
            },
            completion: { [weak self] _ in
                UIView.animate(withDuration: 0.1) {
                    self?.alpha = 1
                }
                self?.onTap?()
            }
        )
    }
}

// MARK: - Setup

extension DropdownMenuItemView {
    private func style() {
        backgroundColor = .clear

        titleLabel.do {
            $0.setTextWithTypography(item.title, style: .body16)
            $0.textColor = item.textColor
        }
    }

    private func layout() {
        addSubview(titleLabel)

        snp.makeConstraints {
            $0.height.equalTo(40)
        }

        titleLabel.snp.makeConstraints {
            $0.leading.equalToSuperview()
            $0.centerY.equalToSuperview()
        }
    }
}
