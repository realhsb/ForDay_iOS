//
//  PeriodSelectionViewController.swift
//  Forday
//
//  Created by Subeen on 1/8/26.
//


import UIKit
import Combine

class PeriodSelectionViewController: BaseOnboardingViewController {

    // Properties

    private let periodView = PeriodSelectionView()
    let viewModel: PeriodSelectionViewModel
    private var autoAdvanceWorkItem: DispatchWorkItem?
    
    // Initialization
    
    init(viewModel: PeriodSelectionViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // Lifecycle
    
    override func loadView() {
        view = periodView
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setNavigationTitle("취미 정보")
        hideNextButton()
        setupCollectionView()
        bind()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        updateProgress(1.0)  // 5/5 = 100%
        setupHobbyCard()
    }

    // Actions

    private func autoAdvance() {
        print("Selected period: \(viewModel.selectedPeriod?.title ?? "None")")

        guard let onboardingCoordinator = coordinator as? OnboardingCoordinator else {
            return
        }

        // 이전 자동 진행 작업 취소
        autoAdvanceWorkItem?.cancel()

        let onboardingData = onboardingCoordinator.getOnboardingData()
        let viewModel = self.viewModel  // viewModel을 직접 캡처 (weak self 불필요)

        // 약간의 딜레이 후 취미 생성
        let workItem = DispatchWorkItem {
            Task { @MainActor in
                await viewModel.createHobby(with: onboardingData)
            }
        }
        autoAdvanceWorkItem = workItem

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.6, execute: workItem)
    }
}

// Setup

extension PeriodSelectionViewController {
    private func setupHobbyCard() {
        guard let onboardingData = coordinator?.getOnboardingData(),
              let hobbyCard = onboardingData.selectedHobbyCard else {
            return
        }

        // 아이콘 이미지 설정
        let icon = hobbyCard.imageAsset.icon

        // 시간 정보 설정
        let time = onboardingData.timeMinutes > 0 ? "\(onboardingData.timeMinutes)분" : nil

        // 횟수 정보 설정
        let frequency = onboardingData.executionCount > 0 ? "주 \(onboardingData.executionCount)회" : nil

        // 목적 정보 설정 (빈 문자열이 아닐 때만)
        let purpose = !onboardingData.purpose.isEmpty ? onboardingData.purpose : nil

        periodView.configureHobbyCard(
            icon: icon,
            title: hobbyCard.name,
            time: time,
            frequency: frequency,
            purpose: purpose
        )
    }

    private func setupCollectionView() {
        periodView.collectionView.delegate = self
        periodView.collectionView.dataSource = self
    }

    private func bind() {
        // 선택된 기간 변경 시 CollectionView 업데이트
        viewModel.$selectedPeriod
            .receive(on: DispatchQueue.main)
            .sink { [weak self] _ in
                self?.periodView.collectionView.reloadData()
            }
            .store(in: &cancellables)

        // 실제 선택이 발생했을 때만 자동 진행 (초기값 무시)
        viewModel.$selectedPeriod
            .dropFirst()  // 초기값(nil) 무시
            .compactMap { $0 }  // nil이 아닐 때만
            .receive(on: DispatchQueue.main)
            .sink { [weak self] _ in
                self?.autoAdvance()
            }
            .store(in: &cancellables)

        // 로딩 상태 변경
        viewModel.$isLoading
            .receive(on: DispatchQueue.main)
            .sink { [weak self] isLoading in
                // TODO: 로딩 인디케이터 표시
                if isLoading {
                    print("⏳ 취미 생성 중...")
                }
            }
            .store(in: &cancellables)

        // 에러 메시지 표시
        viewModel.$errorMessage
            .receive(on: DispatchQueue.main)
            .sink { [weak self] errorMessage in
                if let error = errorMessage {
                    print("❌ 에러: \(error)")
                    // TODO: 에러 얼럿 표시
                }
            }
            .store(in: &cancellables)
    }
}

// UICollectionViewDataSource

extension PeriodSelectionViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return viewModel.periods.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(
            withReuseIdentifier: PeriodOptionCell.identifier,
            for: indexPath
        ) as? PeriodOptionCell else {
            return UICollectionViewCell()
        }
        
        let period = viewModel.periods[indexPath.item]
        let isSelected = viewModel.isSelected(at: indexPath.item)
        cell.configure(with: period, isSelected: isSelected)
        
        return cell
    }
}

// UICollectionViewDelegate

extension PeriodSelectionViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        viewModel.selectPeriod(at: indexPath.item)
        periodView.selectedHobbyCard.setSelected(true)
    }
}

// UICollectionViewDelegateFlowLayout

extension PeriodSelectionViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        // 정사각형 셀: (화면 너비 - 20 - 8 - 20) / 2
        let spacing: CGFloat = 8
        let horizontalPadding: CGFloat = 20 * 2  // leading + trailing
        let cellSize = (collectionView.bounds.width - spacing) / 2

        return CGSize(width: cellSize, height: cellSize)
    }
}

#Preview {
    let nav = UINavigationController()
    let coordinator = OnboardingCoordinator(navigationController: nav)
    coordinator.show(.period)
    return nav
}
