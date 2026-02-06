//
//  SplashView.swift
//  Forday
//
//  Created by Subeen on 2/6/26.
//


import UIKit
import SnapKit
import Then

class SplashView: UIView {

    // UI Components

    private let logoImageView = UIImageView()

    // Initialization

    override init(frame: CGRect) {
        super.init(frame: frame)
        style()
        layout()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

// Setup

extension SplashView {
    private func style() {
        backgroundColor = .neutralWhite

        logoImageView.do {
            $0.image = .App.splash
            $0.contentMode = .scaleAspectFit
        }
    }

    private func layout() {
        addSubview(logoImageView)

        logoImageView.snp.makeConstraints {
            $0.center.equalToSuperview()
            $0.width.equalTo(120)
            $0.height.equalTo(40)
        }
    }
}

#if DEBUG
#Preview {
    SplashView()
}
#endif
