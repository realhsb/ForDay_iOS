//
//  SplashViewController.swift
//  Forday
//
//  Created by Subeen on 2/6/26.
//


import UIKit

class SplashViewController: UIViewController {

    // Properties

    private let splashView = SplashView()

    /// 스플래시 완료 후 호출되는 콜백
    var onSplashComplete: (() -> Void)?

    // Lifecycle

    override func loadView() {
        view = splashView
    }

    override func viewDidLoad() {
        super.viewDidLoad()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        startSplashTimer()
    }

    // Methods

    private func startSplashTimer() {
        // 1.5초 후 다음 화면으로 전환
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) { [weak self] in
            self?.onSplashComplete?()
        }
    }
}

#if DEBUG
#Preview {
    SplashViewController()
}
#endif
