//
//  MainTabBarCoordinator.swift
//  Forday
//
//  Created by Subeen on 1/11/26.
//


import UIKit

class MainTabBarCoordinator: NSObject, Coordinator {


    let navigationController: UINavigationController
    let tabBarController: UITabBarController = UITabBarController()

    weak var parentCoordinator: AppCoordinator?
    private weak var homeViewController: HomeViewController?

    init(navigationController: UINavigationController) {
        self.navigationController = navigationController
        super.init()
    }

    func start() {
        setupTabBar()
    }

    private func setupTabBar() {
        // 홈 탭
        let homeVC = HomeViewController()
        homeVC.coordinator = self
        homeVC.tabBarItem = UITabBarItem(
            title: "홈",
            image: .Gnb.home,
            selectedImage: .Gnb.homeFill
        )
        self.homeViewController = homeVC
        let homeNav = createNavigationController(rootViewController: homeVC)

        // 발견 탭
        let recommendVC = UIViewController()
        recommendVC.view.backgroundColor = .systemBackground
        recommendVC.title = "발견"
        recommendVC.tabBarItem = UITabBarItem(
            title: "발견",
            image: .Gnb.recommendation,
            selectedImage: .Gnb.recommendationFill
        )
        let recommendNav = createNavigationController(rootViewController: recommendVC)

        // 작성 탭 (더미 - 실제로는 presentActivityWrite()에서 present됨)
        let writeVC = UIViewController()
        writeVC.tabBarItem = UITabBarItem(
            title: "",
            image: .Gnb.write,
            selectedImage: .Gnb.write
        )

        // 소식 탭
        let storyVC = UIViewController()
        storyVC.view.backgroundColor = .systemBackground
        storyVC.title = "소식"
        storyVC.tabBarItem = UITabBarItem(
            title: "소식",
            image: .Gnb.story,
            selectedImage: .Gnb.storyFill
        )
        let storyNav = createNavigationController(rootViewController: storyVC)

        // 프로필 탭
        let profileVC = MyPageViewController()
        profileVC.view.backgroundColor = .systemBackground
        profileVC.title = "마이"
        profileVC.tabBarItem = UITabBarItem(
            title: "마이",
            image: .Gnb.myPage,
            selectedImage: .Gnb.myPageFill
        )
        let profileNav = createNavigationController(rootViewController: profileVC)

        // TabBar 설정
        tabBarController.viewControllers = [
            homeNav,
            recommendNav,
            writeVC,
            storyNav,
            profileNav,
        ]
        
        tabBarController.delegate = self
        tabBarController.tabBar.tintColor = .neutral900
    }

    private func createNavigationController(rootViewController: UIViewController) -> UINavigationController {
        let nav = UINavigationController(rootViewController: rootViewController)

        // 네비게이션 바 기본 설정
        nav.navigationBar.prefersLargeTitles = false
        nav.navigationBar.isTranslucent = true

        // 네비게이션 바를 상태바 바로 아래에 배치
        let appearance = UINavigationBarAppearance()
        appearance.configureWithDefaultBackground()
        nav.navigationBar.standardAppearance = appearance
        nav.navigationBar.scrollEdgeAppearance = appearance
        nav.navigationBar.compactAppearance = appearance

        return nav
    }
}

// MARK: - UITabBarControllerDelegate

extension MainTabBarCoordinator: UITabBarControllerDelegate {
    func tabBarController(_ tabBarController: UITabBarController, shouldSelect viewController: UIViewController) -> Bool {
        
        // 가운데 탭(index 2) 선택 시
        if let viewControllers = tabBarController.viewControllers,
           viewControllers.firstIndex(of: viewController) == 2 {
            
            // ActivityWriteViewController present
            presentActivityWrite()
            
            return false  // 탭 전환 막음
        }
        
        return true  // 다른 탭은 정상 전환
    }
    
    private func presentActivityWrite() {
        // HomeViewController에서 currentHobbyId 가져오기
        guard let hobbyId = homeViewController?.getCurrentHobbyId() else {
            print("❌ 취미 ID 없음 - ActivityWriteViewController를 표시할 수 없습니다")
            return
        }

        let writeVC = ActivityWriteViewController(hobbyId: hobbyId)
        let nav = UINavigationController(rootViewController: writeVC)
        nav.modalPresentationStyle = .fullScreen

        // 현재 선택된 탭의 ViewController에서 present
        if let selectedVC = tabBarController.selectedViewController {
            selectedVC.present(nav, animated: true)
        }
    }
}
