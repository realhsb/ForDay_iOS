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
    private let titleLabel = UILabel()
    private let previousButton = UIButton(type: .system)
    private let nextButton = UIButton(type: .system)
    private let stickerGridView = StickerGridView()
    private let emptyStateLabel = UILabel()
    private let activityIndicator = UIActivityIndicatorView(style: .medium)

    // MARK: - Properties

    private var onPreviousPage: (() -> Void)?
    private var onNextPage: (() -> Void)?
    private var onStickerTap: ((Int) -> Void)?

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

    // MARK: - Setup
    
    private func style() {
        titleLabel.do {
            $0.textColor = .neutral900
        }
        
        previousButton.do {
            $0.setImage(.Icon.chevronLeft, for: .normal)
            $0.tintColor = .neutral400
        }
        
        nextButton.do {
            $0.setImage(.Icon.chevronRight, for: .normal)
            $0.tintColor = .neutral400
        }
        
        emptyStateLabel.do {
            $0.setTextWithTypography("아직 시작한 취미가 없어요", style: .body16)
            $0.textColor = .neutral600
            $0.textAlignment = .center
            $0.isHidden = true
        }
        
        activityIndicator.do {
            $0.hidesWhenStopped = true
        }
    }

    private func layout() {
        addSubview(headerView)
        addSubview(stickerGridView)
        addSubview(emptyStateLabel)
        addSubview(activityIndicator)

        headerView.addSubview(titleLabel)
        headerView.addSubview(previousButton)
        headerView.addSubview(nextButton)

        headerView.snp.makeConstraints {
            $0.top.equalToSuperview().offset(16)
            $0.leading.trailing.equalToSuperview()
            $0.height.equalTo(44)
        }

        titleLabel.snp.makeConstraints {
            $0.leading.equalToSuperview().inset(20)
            $0.centerY.equalToSuperview()
        }

        nextButton.snp.makeConstraints {
            $0.trailing.equalToSuperview().inset(20)
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
            $0.leading.trailing.equalToSuperview().inset(20)
            $0.bottom.equalToSuperview().inset(20)
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
        titleLabel.setTextWithTypography("현재까지 \(board.totalStickerNum)개의 스티커 수집", style: .header14)

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
        emptyStateLabel.setTextWithTypography("아직 시작한 취미가 없어요", style: .body16)
        emptyStateLabel.isHidden = false
        activityIndicator.stopAnimating()
        titleLabel.setTextWithTypography("스티커 수집", style: .header14)
        previousButton.isEnabled = false
        previousButton.alpha = 0.3
        nextButton.isEnabled = false
        nextButton.alpha = 0.3
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
        emptyStateLabel.setTextWithTypography(message, style: .body16)
        emptyStateLabel.isHidden = false
        activityIndicator.stopAnimating()
    }
}

#if DEBUG
#Preview {
    StickerBoardView()
}
#endif
