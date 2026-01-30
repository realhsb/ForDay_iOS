//
//  TimeSelectionViewController.swift
//  Forday
//
//  Created by Subeen on 1/6/26.
//


import UIKit
import Combine

class TimeSelectionViewController: BaseOnboardingViewController {

    // Properties

    private let timeView = TimeSelectionView()
    let viewModel: TimeSelectionViewModel
    private var autoAdvanceWorkItem: DispatchWorkItem?
    
    // Initialization
    
    init(viewModel: TimeSelectionViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // Lifecycle
    
    override func loadView() {
        view = timeView
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setNavigationTitle("취미 시간")
        hideNextButton()
        setupHobbyCard()
        setupSlider()
        bind()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        updateProgress(0.4)
    }

    private func setupHobbyCard() {
        guard let onboardingData = coordinator?.getOnboardingData(),
              let hobbyCard = onboardingData.selectedHobbyCard else {
            return
        }

        // 아이콘 이미지 설정
        let icon = hobbyCard.imageAsset.image

        timeView.configureHobbyCard(icon: icon, title: hobbyCard.name)
    }

    // Actions

    private func autoAdvance() {
        guard let selectedTime = viewModel.selectedTime else { return }

        // 이전 자동 진행 작업 취소
        autoAdvanceWorkItem?.cancel()

        // Coordinator에게 데이터 전달
        viewModel.selectTime(selectedTime)

        // 다음 화면으로 (약간의 딜레이 후)
        let workItem = DispatchWorkItem { [weak self] in
            self?.coordinator?.next(from: .time)
        }
        autoAdvanceWorkItem = workItem

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.6, execute: workItem)
    }
}

// Setup

extension TimeSelectionViewController {
    private func setupSlider() {
        timeView.timeSlider.onValueChanged = { [weak self] time in
            self?.viewModel.selectTime(time)
            self?.timeView.selectedHobbyCard.setSelected(true)
            self?.autoAdvance()
        }
    }

    private func bind() {
        // 슬라이더는 항상 활성화되어 있으므로 바인딩 불필요
    }
}

#Preview {
    let nav = UINavigationController()
    let coordinator = OnboardingCoordinator(navigationController: nav)
    coordinator.show(.time)
    return nav
}
