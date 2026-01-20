//
//  HomeView.swift
//  Forday
//
//  Created by Subeen on 1/14/26.
//


import UIKit
import SnapKit
import Then
//import Lott

class HomeView: UIView {
    
    // Properties
    
    private let backgroundImageView = UIImageView()
    
    private let scrollView = UIScrollView()
    private let contentView = UIView()
    
    // Header
    private let headerView = UIView()
    let hobbyDropdownButton = UIButton()
    let notificationButton = UIButton()
    
    // Banner
    private let bannerView = UIView()
    
    // My Activity Section
    private let myActivitySectionView = UIView()
    private let myActivityTitleLabel = UILabel()
    let myActivityChevronButton = UIButton()
    
    // Activity Card
    let activityCardView = UIView()
    let emptyActivityLabel = UILabel()
    let activityDropdownButton = UIButton()
    let addActivityButton = UIButton()
    
    // Sticker Collection Section
    private let stickerSectionView = UIView()
    private let stickerTitleLabel = UILabel()
    let stickerGridView = UIView()  // 나중에 구현
    
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

extension HomeView {
    private func style() {
        backgroundColor = .systemBackground
        
        backgroundImageView.do {
            $0.image = .App.background
            $0.contentMode = .scaleAspectFill
        }
        
        scrollView.do {
            $0.showsVerticalScrollIndicator = false
        }
        
        // Header
        headerView.do {
            $0.backgroundColor = .clear
        }
        
        hobbyDropdownButton.do {
            var config = UIButton.Configuration.plain()
            config.title = "독서"
            config.image = UIImage(systemName: "chevron.down")
            config.imagePlacement = .trailing
            config.imagePadding = 4
            config.baseForegroundColor = .label
            config.titleTextAttributesTransformer = UIConfigurationTextAttributesTransformer { incoming in
                var outgoing = incoming
                outgoing.font = .systemFont(ofSize: 20, weight: .bold)
                return outgoing
            }
            $0.configuration = config
        }
        
        notificationButton.do {
            $0.setImage(UIImage(systemName: "bell"), for: .normal)
            $0.tintColor = .label
        }
        
        // Banner
        bannerView.do {
            $0.layer.shadowOpacity = 0.05
            $0.layer.shadowOffset = CGSize(width: 0, height: 2)
            $0.layer.shadowRadius = 4
        }
        
        // My Activity Section
        myActivityTitleLabel.do {
            $0.setTextWithTypography("나의 취미활동", style: .header16)
            $0.textColor = .neutral900
        }
        
        myActivityChevronButton.do {
            $0.setImage(UIImage(systemName: "chevron.right"), for: .normal)
            $0.tintColor = .systemGray2
        }
        
        // Activity Card - Empty State
        activityCardView.do {
            $0.backgroundColor = .bg001
            $0.layer.cornerRadius = 16
            
            // TODO: shadow custom
            $0.layer.shadowColor = UIColor.black.cgColor
            $0.layer.shadowOpacity = 0.05
            $0.layer.shadowOffset = CGSize(width: 0, height: 2)
            $0.layer.shadowRadius = 4
        }
        
        emptyActivityLabel.do {
            $0.setTextWithTypography("등록된 취미활동이 없어요.", style: .body14)
            $0.textColor = .neutral600
            $0.textAlignment = .center
            $0.isHidden = true // 기본적으로 숨김
        }

        activityDropdownButton.do {
            var config = UIButton.Configuration.plain()
            config.image = UIImage(systemName: "chevron.down")
            config.imagePlacement = .trailing
            config.imagePadding = 8
            config.baseForegroundColor = .label
            config.contentInsets = NSDirectionalEdgeInsets(top: 12, leading: 16, bottom: 12, trailing: 16)
            config.titleTextAttributesTransformer = UIConfigurationTextAttributesTransformer { incoming in
                var outgoing = incoming
                outgoing.font = .systemFont(ofSize: 16, weight: .medium)
                return outgoing
            }
            $0.configuration = config
            $0.contentHorizontalAlignment = .leading
            $0.isHidden = true // 기본적으로 숨김
        }

        addActivityButton.do {
            var config = UIButton.Configuration.filled()
            config.baseBackgroundColor = .primary003
            config.baseForegroundColor = .action001
            config.background.cornerRadius = 12
            config.contentInsets = NSDirectionalEdgeInsets(top: 12, leading: 0, bottom: 12, trailing: 0)

            $0.configuration = config
            $0.setTitleWithTypography("취미활동 추가하기", style: .header14)
        }
        
        // Sticker Section
        stickerSectionView.do {
            $0.backgroundColor = .neutralWhite
            $0.layer.cornerRadius = 20
            $0.layer.shadowColor = UIColor.neutralBlack.cgColor
            
        }
        
        stickerTitleLabel.do {
            $0.text = "현재까지 000개의 스티커 수집"
            $0.applyTypography(.header14)
            $0.textColor = .neutral900
        }
        
        stickerGridView.do {
            $0.backgroundColor = .neutralWhite
            $0.layer.cornerRadius = 16
            $0.layer.borderColor = UIColor.stroke001.cgColor
            $0.layer.borderWidth = 1
        }
    }
    
    private func layout() {
        contentView.insertSubview(backgroundImageView, at: 0)
        
        addSubview(contentView)
//        scrollView.addSubview(contentView)
        
        contentView.addSubview(headerView)
        contentView.addSubview(bannerView)
        contentView.addSubview(myActivitySectionView)
        contentView.addSubview(activityCardView)
        contentView.addSubview(stickerSectionView)
        
        // Header
        headerView.addSubview(hobbyDropdownButton)
        headerView.addSubview(notificationButton)
        
        // My Activity Section
        myActivitySectionView.addSubview(myActivityTitleLabel)
        myActivitySectionView.addSubview(myActivityChevronButton)
        
        // Activity Card
        activityCardView.addSubview(emptyActivityLabel)
        activityCardView.addSubview(activityDropdownButton)
        activityCardView.addSubview(addActivityButton)
        
        // Sticker Section
        stickerSectionView.addSubview(stickerTitleLabel)
        stickerSectionView.addSubview(stickerGridView)
        
        backgroundImageView.snp.makeConstraints {
            $0.center.equalToSuperview()
            // safe area 포함 세로 길이 - 66*2
            $0.width.height.equalTo(UIScreen.main.bounds.height)
        }
        
        contentView.clipsToBounds = true
        
        // ContentView
        contentView.snp.makeConstraints {
            $0.edges.equalTo(safeAreaLayoutGuide)
        }
        
        // Header
        headerView.snp.makeConstraints {
            $0.top.leading.trailing.equalToSuperview()
            $0.height.equalTo(54)
        }
        
        hobbyDropdownButton.snp.makeConstraints {
            $0.leading.equalToSuperview().offset(20)
            $0.bottom.equalToSuperview().offset(-12)
        }
        
        notificationButton.snp.makeConstraints {
            $0.trailing.equalToSuperview().offset(-20)
            $0.centerY.equalTo(hobbyDropdownButton)
            $0.width.height.equalTo(24)
        }
        
        // Banner
        bannerView.snp.makeConstraints {
            $0.top.equalTo(headerView.snp.bottom)
            $0.leading.equalToSuperview().offset(20)
            $0.trailing.equalToSuperview().offset(-20)
        }
        
        // My Activity Section
        myActivitySectionView.snp.makeConstraints {
            $0.top.equalTo(bannerView.snp.bottom).offset(25)
            $0.leading.equalToSuperview().offset(20)
            $0.trailing.equalToSuperview().offset(-20)
            $0.height.equalTo(24)
        }
        
        myActivityTitleLabel.snp.makeConstraints {
            $0.leading.centerY.equalToSuperview()
        }
        
        myActivityChevronButton.snp.makeConstraints {
            $0.trailing.centerY.equalToSuperview()
            $0.width.height.equalTo(24)
        }
        
        // Activity Card
        activityCardView.snp.makeConstraints {
            $0.top.equalTo(myActivitySectionView.snp.bottom).offset(12)
            $0.leading.trailing.equalToSuperview().inset(20)
        }
        
        emptyActivityLabel.snp.makeConstraints {
            $0.top.equalToSuperview().offset(24)
            $0.leading.trailing.equalToSuperview().inset(20)
        }

        activityDropdownButton.snp.makeConstraints {
            $0.top.equalToSuperview().offset(20)
            $0.leading.trailing.equalToSuperview().inset(20)
        }

        addActivityButton.snp.makeConstraints {
            $0.top.equalTo(emptyActivityLabel.snp.bottom).offset(16)
            $0.leading.equalToSuperview().offset(20)
            $0.trailing.equalToSuperview().offset(-20)
            $0.bottom.equalToSuperview().offset(-24)
        }
        
        // Sticker Section
        stickerSectionView.snp.makeConstraints {
            $0.top.equalTo(activityCardView.snp.bottom).offset(20)
            $0.leading.trailing.equalToSuperview()
            $0.bottom.equalToSuperview().offset(-100) // TabBar 공간
        }
        
        stickerTitleLabel.snp.makeConstraints {
            $0.top.equalToSuperview().offset(40)
            $0.leading.trailing.equalToSuperview().inset(20)
        }
        
        stickerGridView.snp.makeConstraints {
            $0.top.equalTo(stickerTitleLabel.snp.bottom).offset(12)
            $0.leading.trailing.bottom.equalToSuperview().inset(20)
            $0.height.equalTo(200) // 임시
        }
    }
}

// Public Methods

extension HomeView {
    func updateActivityPreview(_ activityPreview: ActivityPreview?) {
        if let preview = activityPreview {
            // 활동이 있는 경우
            emptyActivityLabel.isHidden = true
            activityDropdownButton.isHidden = false

            // 드롭다운 버튼 텍스트 설정
            var config = activityDropdownButton.configuration
            config?.title = preview.content
            activityDropdownButton.configuration = config

            // 버튼 텍스트 변경
            addActivityButton.setTitleWithTypography("오늘의 스티커 붙이기", style: .header14)

            // addActivityButton 제약 조건 업데이트 (activityDropdownButton 기준)
            addActivityButton.snp.remakeConstraints {
                $0.top.equalTo(activityDropdownButton.snp.bottom).offset(16)
                $0.leading.equalToSuperview().offset(20)
                $0.trailing.equalToSuperview().offset(-20)
                $0.bottom.equalToSuperview().offset(-24)
            }
        } else {
            // 활동이 없는 경우
            emptyActivityLabel.isHidden = false
            activityDropdownButton.isHidden = true

            // 버튼 텍스트 복원
            addActivityButton.setTitleWithTypography("취미활동 추가하기", style: .header14)

            // addActivityButton 제약 조건 복원 (emptyActivityLabel 기준)
            addActivityButton.snp.remakeConstraints {
                $0.top.equalTo(emptyActivityLabel.snp.bottom).offset(16)
                $0.leading.equalToSuperview().offset(20)
                $0.trailing.equalToSuperview().offset(-20)
                $0.bottom.equalToSuperview().offset(-24)
            }
        }
    }

    func updateStickerCount(_ count: Int) {
        stickerTitleLabel.text = "현재까지 \(count)개의 스티커 수집"
    }
}

#Preview {
    HomeView()
}
