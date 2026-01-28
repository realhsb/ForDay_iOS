//
//  OnboardingCoordinator.swift
//  Forday
//
//  Created by Subeen on 1/6/26.
//


import UIKit

class OnboardingCoordinator: Coordinator {

    // Properties

    let navigationController: UINavigationController
    weak var parentCoordinator: AuthCoordinator?

    // 온보딩 데이터 수집
    private var onboardingData = OnboardingData()
    // 로컬 저장은 더 이상 사용하지 않음 - 서버로 직접 전송
    // private let storage = OnboardingDataStorage.shared

    // Completion handler for hobby creation (used when called from HobbySettings)
    var onHobbyCreationCompleted: (() -> Void)?
    
    // Initialization
    
    init(navigationController: UINavigationController) {
        self.navigationController = navigationController
    }
    
    // Coordinator
    
    func start() {
        show(.hobby)
    }
    
    // Navigation
    
    func show(_ step: OnboardingStep) {
        let vc: UIViewController
        
        switch step {
        case .hobby:
            let viewModel = HobbySelectionViewModel()
            viewModel.onHobbySelected = { [weak self] hobbyCard in
                self?.updateHobby(hobbyCard)
            }
            vc = HobbySelectionViewController(viewModel: viewModel)
            
        case .time:
            let viewModel = TimeSelectionViewModel()
            viewModel.onTimeSelected = { [weak self] minutes in
                self?.updateTime(minutes)
            }
            vc = TimeSelectionViewController(viewModel: viewModel)
            
        case .purpose:
            let viewModel = PurposeSelectionViewModel()
            viewModel.onPurposeSelected = { [weak self] purpose in
                self?.updatePurpose(purpose)
            }
            vc = PurposeSelectionViewController(viewModel: viewModel)
            
        case .frequency:
            let viewModel = FrequencySelectionViewModel()
            viewModel.onFrequencySelected = { [weak self] count in
                self?.updateFrequency(count)
            }
            vc = FrequencySelectionViewController(viewModel: viewModel)
            
        case .period:
            let viewModel = PeriodSelectionViewModel()
            viewModel.onPeriodSelected = { [weak self] isDurationSet in
                self?.updatePeriod(isDurationSet)
            }
            viewModel.onHobbyCreated = { [weak self] hobbyId in
                print("✅ 취미 생성 완료 - hobbyId: \(hobbyId)")

                // If called from HobbySettings, call completion handler instead of navigating
                if let completionHandler = self?.onHobbyCreationCompleted {
                    completionHandler()
                } else {
                    // Normal onboarding flow - proceed to transition screen
                    self?.showNicknameTransition()
                }
            }
            vc = PeriodSelectionViewController(viewModel: viewModel)
            
        case .complete:
            vc = OnboardingCompleteViewController()
            (vc as? OnboardingCompleteViewController)?.coordinator = self
        }
        
        // Coordinator 주입
        if let baseVC = vc as? BaseOnboardingViewController {
            baseVC.coordinator = self
        }
        
        navigationController.pushViewController(vc, animated: true)
    }
    
    func next(from currentStep: OnboardingStep) {
        switch currentStep {
        case .hobby: show(.time)
        case .time: show(.purpose)
        case .purpose: show(.frequency)
        case .frequency: show(.period)
        case .period:
            // API 호출은 ViewModel에서 처리하고, 성공 시 onHobbyCreated 클로저를 통해 여기로 돌아옴
            // Period 완료 후 닉네임 설정 화면으로
            break
        case .complete:
            break
        }
    }
    
    // 닉네임 설정 화면으로 (progress bar 없음, 뒤로가기 불가)
    func showNicknameSetup() {
        let vc = NicknameViewController()
        vc.coordinator = self

        // 재로그인 시: 온보딩 스택 전부 제거하고 닉네임만 표시
        if navigationController.viewControllers.isEmpty {
            navigationController.setViewControllers([vc], animated: true)
        } else {
            // 온보딩 진행 중: 그냥 push
            navigationController.pushViewController(vc, animated: true)
        }
    }

    // 닉네임 전환 화면 표시
    private func showNicknameTransition() {
        let vc = NicknameTransitionViewController()
        vc.coordinator = self
        navigationController.pushViewController(vc, animated: true)
    }

    // 온보딩 완료 화면 표시
    func showOnboardingComplete() {
        show(.complete)
    }

    // 온보딩 완전 종료 (홈으로)
    func finishOnboarding() {
        print("✅ 온보딩 완전 종료 - 홈으로 이동")

        // dismiss하고 AuthCoordinator에 알림
        navigationController.dismiss(animated: true) {
            self.parentCoordinator?.completeOnboarding()
        }
    }
    
    func dismissOnboarding() {
        navigationController.dismiss(animated: true)
    }
}

// MARK: - Data Collection

extension OnboardingCoordinator {
    
    func updateHobby(_ hobbyCard: HobbyCard) {
        onboardingData.selectedHobbyCard = hobbyCard
        print("✅ 취미 저장: \(hobbyCard.name)")
    }
    
    func updateTime(_ minutes: Int) {
        onboardingData.timeMinutes = minutes
        print("✅ 시간 저장: \(minutes)분")
    }
    
    func updatePurpose(_ purpose: String) {
        onboardingData.purpose = purpose
        print("✅ 목적 저장: \(purpose)")
    }
    
    func updateFrequency(_ count: Int) {
        onboardingData.executionCount = count
        print("✅ 횟수 저장: 주 \(count)회")
    }
    
    func updatePeriod(_ isDurationSet: Bool) {
        onboardingData.isDurationSet = isDurationSet
        print("✅ 기간 저장: \(isDurationSet)")
    }

    // 온보딩 데이터 getter - ViewModel에서 사용
    func getOnboardingData() -> OnboardingData {
        return onboardingData
    }

    // 로컬 저장은 더 이상 사용하지 않음 - 서버로 직접 전송
    // private func saveOnboardingData() {
    //     do {
    //         try storage.save(onboardingData)
    //         print("✅ 온보딩 데이터 저장 완료")
    //         print("저장된 데이터: \(onboardingData)")
    //     } catch {
    //         print("❌ 온보딩 데이터 저장 실패: \(error)")
    //     }
    // }
}
