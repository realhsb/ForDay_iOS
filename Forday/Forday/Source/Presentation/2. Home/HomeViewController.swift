//
//  HomeViewController.swift
//  Forday
//
//  Created by Subeen on 1/14/26.
//


import UIKit
import Combine
import SnapKit

class HomeViewController: UIViewController {
    
    // Properties
    
    private let homeView = HomeView()
    private let viewModel = HomeViewModel()
    private var cancellables = Set<AnyCancellable>()
    
    // Coordinator
    weak var coordinator: MainTabBarCoordinator?

    // Dropdown
    private var dropdownBackgroundView: UIView?
    private var activityDropdownView: ActivityDropdownView?
    
    // Lifecycle
    
    override func loadView() {
        view = homeView
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupNavigationBar()
        setupActions()
        bind()

        // 홈 정보 로드
        Task {
            await viewModel.fetchHomeInfo()
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: false)
    }
}

// Setup

extension HomeViewController {
    private func setupNavigationBar() {
        navigationController?.setNavigationBarHidden(true, animated: false)
    }
    
    private func setupActions() {
        // 취미 드롭다운 버튼
        homeView.hobbyDropdownButton.addTarget(
            self,
            action: #selector(hobbyDropdownTapped),
            for: .touchUpInside
        )

        // 알림 버튼
        homeView.notificationButton.addTarget(
            self,
            action: #selector(notificationTapped),
            for: .touchUpInside
        )

        // 나의 취미활동 쉐브론
        homeView.myActivityChevronButton.addTarget(
            self,
            action: #selector(myActivityChevronTapped),
            for: .touchUpInside
        )

        // 활동 드롭다운 버튼
        homeView.activityDropdownButton.addTarget(
            self,
            action: #selector(activityDropdownTapped),
            for: .touchUpInside
        )

        // 취미활동 추가하기 버튼
        homeView.addActivityButton.addTarget(
            self,
            action: #selector(addActivityButtonTapped),
            for: .touchUpInside
        )
    }
    
    private func bind() {
        // 홈 정보 업데이트
        viewModel.$homeInfo
            .receive(on: DispatchQueue.main)
            .sink { [weak self] homeInfo in
                self?.updateUI(with: homeInfo)
            }
            .store(in: &cancellables)

        // 로딩 상태
        viewModel.$isLoading
            .receive(on: DispatchQueue.main)
            .sink { [weak self] isLoading in
                // TODO: 로딩 인디케이터 표시
                print("로딩 상태: \(isLoading)")
            }
            .store(in: &cancellables)

        // 에러 메시지
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

    private func updateUI(with homeInfo: HomeInfo?) {
        guard let homeInfo = homeInfo else {
            return
        }

        // currentHobby가 true인 취미 찾기
        let currentHobby = homeInfo.inProgressHobbies.first { $0.currentHobby }

        // 취미 이름 업데이트
        if let currentHobby = currentHobby {
            var config = homeView.hobbyDropdownButton.configuration
            config?.title = currentHobby.hobbyName
            homeView.hobbyDropdownButton.configuration = config
        }

        // 활동 미리보기 업데이트
        homeView.updateActivityPreview(homeInfo.activityPreview)

        // 스티커 개수 업데이트
        homeView.updateStickerCount(homeInfo.totalStickerNum)
    }
}

// Actions

extension HomeViewController {
    @objc private func hobbyDropdownTapped() {
        print("취미 드롭다운 탭")
        // TODO: 취미 목록 바텀시트
    }
    
    @objc private func notificationTapped() {
        print("알림 탭")
        // TODO: 알림 화면
    }
    
    @objc private func myActivityChevronTapped() {
        print("나의 취미활동 쉐브론 탭")
        showActivityList()
    }

    @objc private func activityDropdownTapped() {
        print("활동 드롭다운 탭")
        showActivityDropdown()
    }

    private func showActivityDropdown() {
        // 기존 드롭다운이 있으면 먼저 제거
        dismissActivityDropdown()

        Task {
            do {
                let activities = try await viewModel.fetchActivityList()

                await MainActor.run {
                    self.presentActivityDropdown(activities: activities)
                }
            } catch {
                await MainActor.run {
                    print("❌ 활동 목록 로드 실패: \(error)")
                }
            }
        }
    }

    private func presentActivityDropdown(activities: [Activity]) {
        // 투명 배경 생성
        let backgroundView = UIView()
        backgroundView.backgroundColor = .clear
        view.addSubview(backgroundView)

        backgroundView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }

        let tapGesture = UITapGestureRecognizer(
            target: self,
            action: #selector(dismissActivityDropdown)
        )
        backgroundView.addGestureRecognizer(tapGesture)

        // 드롭다운 생성
        let dropdownView = ActivityDropdownView(activities: activities)
        dropdownView.onActivitySelected = { [weak self] activity in
            self?.selectActivity(activity)
        }

        // 드롭다운 표시
        dropdownView.show(in: view, below: homeView.activityDropdownButton)

        // 프로퍼티에 참조 저장
        self.dropdownBackgroundView = backgroundView
        self.activityDropdownView = dropdownView
    }

    @objc private func dismissActivityDropdown() {
        // 드롭다운 애니메이션으로 닫기
        activityDropdownView?.dismiss()

        // 배경 제거
        dropdownBackgroundView?.removeFromSuperview()

        // 참조 해제
        activityDropdownView = nil
        dropdownBackgroundView = nil
    }

    private func selectActivity(_ activity: Activity) {
        // 드롭다운 닫기
        dismissActivityDropdown()

        // ActivityPreview 객체 생성
        let activityPreview = ActivityPreview(
            activityId: activity.activityId,
            content: activity.content,
            aiRecommended: activity.aiRecommended
        )

        // HomeInfo 업데이트
        if var homeInfo = viewModel.homeInfo {
            let updatedHomeInfo = HomeInfo(
                inProgressHobbies: homeInfo.inProgressHobbies,
                activityPreview: activityPreview,
                totalStickerNum: homeInfo.totalStickerNum,
                activityRecordedToday: homeInfo.activityRecordedToday,
                aiCallRemaining: homeInfo.aiCallRemaining,
                collectedStickers: homeInfo.collectedStickers
            )

            viewModel.homeInfo = updatedHomeInfo
            homeView.updateActivityPreview(activityPreview)

            print("✅ 활동 선택 완료: \(activity.content)")
        }
    }

    private func showActivityList() {
        // 현재 취미 ID 가져오기
        guard let hobbyId = viewModel.currentHobbyId else {
            print("❌ 취미 ID 없음")
            return
        }

        let activityListVC = ActivityListViewController(hobbyId: hobbyId)
        navigationController?.pushViewController(activityListVC, animated: true)
    }
    
    @objc private func addActivityButtonTapped() {
        // activityPreview 유무에 따라 다른 동작
        if viewModel.homeInfo?.activityPreview != nil {
            // 스티커 붙이기
            print("오늘의 스티커 붙이기 탭")
            // TODO: 스티커 붙이기 API 연동
        } else {
            // 취미활동 추가하기
            print("취미활동 추가하기 탭")
            showActivityInput()
        }
    }

    private func showActivityInput() {
        guard let hobbyId = viewModel.currentHobbyId else {
            print("❌ 취미 ID 없음")
            return
        }

        let inputVC = HobbyActivityInputViewController(hobbyId: hobbyId)
        inputVC.onActivityCreated = { [weak self] in
            // Dismiss modal first, then push ActivityListViewController
            self?.dismiss(animated: true) {
                self?.showActivityListAfterSave()
            }
        }

        let nav = UINavigationController(rootViewController: inputVC)
        nav.modalPresentationStyle = .fullScreen
        present(nav, animated: true)
    }

    private func showActivityListAfterSave() {
        guard let hobbyId = viewModel.currentHobbyId else {
            print("❌ 취미 ID 없음")
            return
        }

        let activityListVC = ActivityListViewController(hobbyId: hobbyId)
        activityListVC.shouldShowAIRecommendationToast = true
        navigationController?.pushViewController(activityListVC, animated: true)
    }

    private func showAIRecommendationModal() {
        let containerVC = AIRecommendationContainerViewController(viewModel: viewModel)
        containerVC.modalPresentationStyle = .pageSheet

        if let sheet = containerVC.sheetPresentationController {
            sheet.detents = [.medium()]
            sheet.prefersGrabberVisible = true
        }

        present(containerVC, animated: true) {
            // 시트 표시 후 토스트를 window에 추가
            self.showToastAboveSheet()
        }

        // 토스트 제거 클로저 전달
        containerVC.onDismissToast = { [weak self] in
            self?.hideToast()
        }
    }

    private func showToastAboveSheet() {
        // window 가져오기
        guard let window = view.window else { return }
        
        // 기존 토스트 제거
        window.subviews.filter { $0 is ToastView }.forEach { $0.removeFromSuperview() }
        
        // 새 토스트 생성
        let toast = ToastView(message: "포데이 AI가 알맞은 취미활동을 추천해드려요")
        toast.tag = 9999 // 나중에 찾기 위한 태그
        
        // window에 추가
        window.addSubview(toast)
        
        // presentedViewController의 view를 기준으로 위치 설정
        if let sheetView = presentedViewController?.view {
            toast.snp.makeConstraints {
                $0.leading.trailing.equalToSuperview().inset(26)
                $0.bottom.equalTo(sheetView.snp.top).offset(-20)  // 시트 top으로부터 20 위
            }
        } 
        
        // 페이드 인
        toast.alpha = 0
        UIView.animate(withDuration: 0.3) {
            toast.alpha = 1
        }
    }

    func hideToast() {
        guard let window = view.window else { return }

        window.subviews.filter { $0.tag == 9999 }.forEach {
            ($0 as? ToastView)?.hide()
        }
    }

    // Public Methods

    func getCurrentHobbyId() -> Int? {
        return viewModel.currentHobbyId
    }
}

#Preview {
    HomeViewController()
}
