//
//  StickerBoardView.swift
//  Forday
//
//  Created by Subeen on 1/23/26.
//

import UIKit
import SnapKit
import Then

final class StickerBoardView: UIView {

    // MARK: - UI Components

    private let headerView = UIView()

    private let titleLabel = UILabel().then {
        $0.font = .systemFont(ofSize: 18, weight: .bold)
        $0.textColor = .label
    }

    private let previousButton = UIButton(type: .system).then {
        $0.setImage(UIImage(systemName: "chevron.left"), for: .normal)
        $0.tintColor = .label
    }

    private let nextButton = UIButton(type: .system).then {
        $0.setImage(UIImage(systemName: "chevron.right"), for: .normal)
        $0.tintColor = .label
    }

    private let stickerGridView = StickerGridView()

    private let emptyStateLabel = UILabel().then {
        $0.text = "아직 시작한 취미가 없어요"
        $0.font = .systemFont(ofSize: 16, weight: .medium)
        $0.textColor = .secondaryLabel
        $0.textAlignment = .center
        $0.isHidden = true
    }

    private let activityIndicator = UIActivityIndicatorView(style: .medium).then {
        $0.hidesWhenStopped = true
    }

    // MARK: - Properties

    private var onPreviousPage: (() -> Void)?
    private var onNextPage: (() -> Void)?
    private var onStickerTap: ((Int) -> Void)?

    // MARK: - Initialization

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
        setupActions()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Setup

    private func setupUI() {
        addSubview(headerView)
        addSubview(stickerGridView)
        addSubview(emptyStateLabel)
        addSubview(activityIndicator)

        headerView.addSubview(titleLabel)
        headerView.addSubview(previousButton)
        headerView.addSubview(nextButton)

        headerView.snp.makeConstraints {
            $0.top.leading.trailing.equalToSuperview()
            $0.height.equalTo(44)
        }

        titleLabel.snp.makeConstraints {
            $0.leading.equalToSuperview().inset(16)
            $0.centerY.equalToSuperview()
        }

        nextButton.snp.makeConstraints {
            $0.trailing.equalToSuperview().inset(16)
            $0.centerY.equalToSuperview()
            $0.size.equalTo(32)
        }

        previousButton.snp.makeConstraints {
            $0.trailing.equalTo(nextButton.snp.leading).offset(-8)
            $0.centerY.equalToSuperview()
            $0.size.equalTo(32)
        }

        stickerGridView.snp.makeConstraints {
            $0.top.equalTo(headerView.snp.bottom).offset(8)
            $0.leading.trailing.equalToSuperview().inset(16)
            $0.bottom.equalToSuperview().inset(16)
        }

        emptyStateLabel.snp.makeConstraints {
            $0.center.equalTo(stickerGridView)
        }

        activityIndicator.snp.makeConstraints {
            $0.center.equalTo(stickerGridView)
        }
    }

    private func setupActions() {
        previousButton.addTarget(self, action: #selector(didTapPrevious), for: .touchUpInside)
        nextButton.addTarget(self, action: #selector(didTapNext), for: .touchUpInside)
    }

    @objc private func didTapPrevious() {
        onPreviousPage?()
    }

    @objc private func didTapNext() {
        onNextPage?()
    }

    // MARK: - Configuration

    func configure(
        with board: StickerBoard,
        onPreviousPage: @escaping () -> Void,
        onNextPage: @escaping () -> Void,
        onStickerTap: @escaping (Int) -> Void
    ) {
        self.onPreviousPage = onPreviousPage
        self.onNextPage = onNextPage
        self.onStickerTap = onStickerTap

        // 헤더 텍스트
        titleLabel.text = "현재까지 \(board.totalStickerNum)개의 스티커 수집"

        // 페이지네이션 버튼 상태
        previousButton.isEnabled = board.hasPrevious
        previousButton.alpha = board.hasPrevious ? 1.0 : 0.3

        nextButton.isEnabled = board.hasNext
        nextButton.alpha = board.hasNext ? 1.0 : 0.3

        // 그리드 표시
        stickerGridView.configure(with: board, onStickerTap: onStickerTap)
        stickerGridView.isHidden = false
        emptyStateLabel.isHidden = true
        activityIndicator.stopAnimating()
    }

    func showLoading() {
        stickerGridView.isHidden = true
        emptyStateLabel.isHidden = true
        activityIndicator.startAnimating()
    }

    func showNoHobby() {
        stickerGridView.isHidden = true
        emptyStateLabel.text = "아직 시작한 취미가 없어요"
        emptyStateLabel.isHidden = false
        activityIndicator.stopAnimating()
        titleLabel.text = "스티커 수집"
        previousButton.isEnabled = false
        nextButton.isEnabled = false
    }

    func showEmpty(board: StickerBoard) {
        // 취미는 있지만 스티커가 0개
        configure(
            with: board,
            onPreviousPage: onPreviousPage ?? {},
            onNextPage: onNextPage ?? {},
            onStickerTap: onStickerTap ?? { _ in }
        )
    }

    func showError(message: String) {
        stickerGridView.isHidden = true
        emptyStateLabel.text = message
        emptyStateLabel.isHidden = false
        activityIndicator.stopAnimating()
    }
}
