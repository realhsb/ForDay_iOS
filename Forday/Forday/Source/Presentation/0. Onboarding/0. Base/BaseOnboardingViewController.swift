//
//  BaseOnboardingViewController.swift
//  Forday
//
//  Created by Subeen on 1/5/26.
//

import UIKit
import SnapKit
import Then
import Combine

class BaseOnboardingViewController: UIViewController {
    
    /// Properties
    
    let nextButton = UIButton(type: .system)
    private let progressBar = UIProgressView()
    var cancellables = Set<AnyCancellable>()
    
    /// Layout Constants (수정 가능)
    
    var horizontalPadding: CGFloat = 20
    var nextButtonHeight: CGFloat = 56
    var nextButtonBottomMargin: CGFloat = 16

    override func viewDidLoad() {
        super.viewDidLoad()
        style()
        layout()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setupProgressBar()
    }
}

extension BaseOnboardingViewController {
    private func style() {
        view.backgroundColor = .systemBackground
        
        // 내비게이션 바
        let backButton = UIBarButtonItem(
            image: UIImage(systemName: "chevron.left"),
            style: .plain,
            target: self,
            action: #selector(backButtonTapped)
        )
        backButton.tintColor = .label
        navigationItem.leftBarButtonItem = backButton
        navigationController?.navigationBar.prefersLargeTitles = false
        
        // 프로그래스바
        progressBar.do {
            $0.progressTintColor = .systemOrange
            $0.trackTintColor = .systemGray5
            $0.progress = 0
        }
        
        // 다음 버튼
        nextButton.do {
            $0.setTitle("다음", for: .normal)
            $0.titleLabel?.font = .systemFont(ofSize: 17, weight: .semibold)
            $0.backgroundColor = .systemOrange
            $0.setTitleColor(.white, for: .normal)
            $0.setTitleColor(.white.withAlphaComponent(0.5), for: .disabled)
            $0.layer.cornerRadius = 12
            $0.isEnabled = false
            $0.addTarget(self, action: #selector(nextButtonTapped), for: .touchUpInside)
        }
    }
    
    private func layout() {
        view.addSubview(nextButton)
        
        nextButton.snp.makeConstraints {
            $0.leading.trailing.equalToSuperview().inset(horizontalPadding)
            $0.bottom.equalTo(view.safeAreaLayoutGuide).offset(-nextButtonBottomMargin)
            $0.height.equalTo(nextButtonHeight)
        }
    }
    
    private func setupProgressBar() {
        guard let navigationBar = navigationController?.navigationBar else { return }
        
        // 이미 추가되어 있으면 제거 (중복 방지)
        progressBar.removeFromSuperview()
        
        navigationBar.addSubview(progressBar)
        
        progressBar.snp.makeConstraints {
            $0.leading.trailing.equalToSuperview()
            $0.bottom.equalToSuperview()
            $0.height.equalTo(4)
        }
    }
}

// Public Methods

extension BaseOnboardingViewController {
    /// 내비게이션 타이틀 설정
    func setNavigationTitle(_ title: String) {
        navigationItem.title = title
    }
    
    /// 다음 버튼 활성화 상태 설정
    func setNextButtonEnabled(_ isEnabled: Bool) {
        nextButton.isEnabled = isEnabled
        UIView.animate(withDuration: 0.2) {
            self.nextButton.backgroundColor = isEnabled
                ? .systemOrange 
                : .systemGray4
        }
    }
    
    /// 프로그래스바 업데이트
    func updateProgress(_ progress: Float) {
        UIView.animate(withDuration: 0.3) {
            self.progressBar.setProgress(progress, animated: true)
        }
    }
}

// Actions

extension BaseOnboardingViewController {
    /// 뒤로가기 버튼 액션 (필요시 오버라이드)
    @objc func backButtonTapped() {
        navigationController?.popViewController(animated: true)
    }
    
    /// 다음 버튼 액션 (반드시 오버라이드 필요)
    @objc func nextButtonTapped() {
        fatalError("nextButtonTapped() must be overridden by subclass")
    }
}
