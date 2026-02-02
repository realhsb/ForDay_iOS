//
//  HobbyCardStackViewController.swift
//  Forday
//
//  Created by Subeen on 1/23/26.
//

import UIKit
import SnapKit
import Then
import Combine

final class HobbyCardStackViewController: UIViewController {

    // MARK: - Properties

    private let viewModel: MyPageViewModel
    private var cancellables = Set<AnyCancellable>()

    private let titleLabel = UILabel()
    private let cardStackView = HobbyCardStackView()
    private let emptyStateView = EmptyStateView()

    // MARK: - Initialization

    init(viewModel: MyPageViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        style()
        layout()
        bind()
    }
}

// MARK: - Setup

extension HobbyCardStackViewController {
    private func style() {
        view.backgroundColor = .systemBackground

        titleLabel.do {
            $0.text = "66일이 지속된 취미카드예요!"
            $0.font = .systemFont(ofSize: 20, weight: .bold)
            $0.textColor = .label
            $0.textAlignment = .left
        }
    }

    private func layout() {
        view.addSubview(titleLabel)
        view.addSubview(cardStackView)

        titleLabel.snp.makeConstraints {
            $0.top.equalToSuperview().offset(20)
            $0.leading.equalToSuperview().offset(20)
            $0.trailing.equalToSuperview().offset(-20)
        }

        cardStackView.snp.makeConstraints {
            $0.top.equalTo(titleLabel.snp.bottom).offset(20)
            $0.leading.equalToSuperview().offset(20)
            $0.trailing.equalToSuperview().offset(-20)
            $0.bottom.lessThanOrEqualToSuperview().offset(-40)
            $0.height.equalTo(cardStackView.snp.width).multipliedBy(1.5) // 2:3 aspect ratio
        }
    }

    private func bind() {
        viewModel.$hobbyCards
            .receive(on: DispatchQueue.main)
            .sink { [weak self] cards in
                self?.updateContent(cards: cards)
            }
            .store(in: &cancellables)
    }

    private func updateContent(cards: [CompletedHobbyCard]) {
        if cards.isEmpty {
            // Show empty state
            cardStackView.isHidden = true
            titleLabel.isHidden = true

            if emptyStateView.superview == nil {
                view.addSubview(emptyStateView)
                emptyStateView.snp.makeConstraints {
                    $0.edges.equalToSuperview()
                }
            }

            emptyStateView.configure(
                icon: UIImage(systemName: "rectangle.stack"),
                message: "66일을 완료한 취미카드가 없습니다.\n취미를 완료하면 카드가 생성됩니다!",
                actionTitle: nil
            )
        } else {
            // Show cards
            cardStackView.isHidden = false
            titleLabel.isHidden = false
            emptyStateView.removeFromSuperview()

            cardStackView.configure(with: cards)
        }
    }
}
