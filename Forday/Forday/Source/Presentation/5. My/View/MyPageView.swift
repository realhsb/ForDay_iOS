//
//  MyPageView.swift
//  Forday
//
//  Created by Subeen on 1/23/26.
//

import UIKit
import SnapKit
import Then

final class MyPageView: UIView {

    // MARK: - Properties

    let headerView = MyPageHeaderView()
    let segmentedControlView = MyPageSegmentedControlView()
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
}

// MARK: - Setup

extension MyPageView {
    private func style() {
        backgroundColor = .systemBackground

        contentContainerView.do {
            $0.backgroundColor = .systemBackground
        }
    }

    private func layout() {
        addSubview(headerView)
        addSubview(segmentedControlView)
        addSubview(contentContainerView)

        headerView.snp.makeConstraints {
            $0.top.equalTo(safeAreaLayoutGuide)
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
            $0.bottom.equalTo(safeAreaLayoutGuide)
        }
    }
}

#Preview {
    MyPageView()
}
