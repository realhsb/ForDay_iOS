//
//  MainTabBarCoordinator.swift
//  Forday
//
//  Created by Subeen on 1/11/26.
//


import UIKit

class MainTabBarCoordinator: Coordinator {
    
    
    let navigationController: UINavigationController
    let tabBarController: UITabBarController = UITabBarController()
    
    weak var parentCoordinator: AppCoordinator?
    
    init(navigationController: UINavigationController) {
        self.navigationController = navigationController
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
        
        // 발견 탭
        let recommendVC = UIViewController()
        recommendVC.view.backgroundColor = .systemBackground
        recommendVC.title = "발견"
        recommendVC.tabBarItem = UITabBarItem(
            title: "발견",
            image: .Gnb.recommendation,
            selectedImage: .Gnb.recommendationFill
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
        
        // 프로필 탭
        let profileVC = UIViewController()
        profileVC.view.backgroundColor = .systemBackground
        profileVC.title = "마이"
        profileVC.tabBarItem = UITabBarItem(
            title: "마이",
            image: .Gnb.myPage,
            selectedImage: .Gnb.myPageFill
        )
        
        // TabBar 설정
        tabBarController.viewControllers = [
            UINavigationController(rootViewController: homeVC),
            UINavigationController(rootViewController: recommendVC),
            UINavigationController(rootViewController: storyVC),
            UINavigationController(rootViewController: profileVC),
        ]
        
        tabBarController.tabBar.tintColor = .systemOrange
    }
}
