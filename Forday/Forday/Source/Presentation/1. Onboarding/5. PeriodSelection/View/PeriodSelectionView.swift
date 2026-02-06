//
//  PeriodSelectionView.swift
//  Forday
//
//  Created by Subeen on 1/8/26.
//


import UIKit
import SnapKit
import Then

class PeriodSelectionView: UIView {
    
    // Properties
    
    private let contentView = UIView()
    
    let titleLabel = UILabel()
    let subtitleLabel = UILabel()
    let selectedHobbyCard = SelectedHobbyCardView()
    let collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        layout.minimumLineSpacing = 8  // 셀 사이 간격
        layout.minimumInteritemSpacing = 8
        return UICollectionView(frame: .zero, collectionViewLayout: layout)
    }()
    
    // Initialization
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        style()
        layout()
    }

    // Configure

    func configureHobbyCard(icon: UIImage?, title: String, time: String?, frequency: String?, purpose: String?) {
        selectedHobbyCard.configure(icon: icon, title: title)
        selectedHobbyCard.updateInfo(time: time, frequency: frequency, purpose: purpose)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

// Setup

extension PeriodSelectionView {
    private func style() {
        backgroundColor = .bg001
        
        titleLabel.do {
            $0.setTextWithTypography("이 취미, 어떻게 이어가볼까요?", style: .header20)
            $0.textColor = .neutral900
            $0.numberOfLines = 0
        }

        subtitleLabel.do {
            $0.setTextWithTypography("며칠동안 해볼까요?\n하루에 1개씩 꾸준히 기록을 남겨봐요.", style: .label14)
            $0.textColor = .neutral800
            $0.numberOfLines = 0
        }
        
        collectionView.do {
            $0.backgroundColor = .clear
            $0.isScrollEnabled = false  // 스크롤 비활성화
            $0.register(PeriodOptionCell.self, forCellWithReuseIdentifier: PeriodOptionCell.identifier)
        }
    }
    
    private func layout() {
        addSubview(contentView)
        
        contentView.addSubview(titleLabel)
        contentView.addSubview(subtitleLabel)
        contentView.addSubview(selectedHobbyCard)
        contentView.addSubview(collectionView)
        
        // ContentView
        contentView.snp.makeConstraints {
            $0.top.equalTo(safeAreaLayoutGuide).offset(48)
            $0.leading.equalToSuperview().offset(20)
            $0.trailing.equalToSuperview().offset(-20)
            $0.bottom.equalToSuperview()
        }
        
        // Title
        titleLabel.snp.makeConstraints {
            $0.top.equalToSuperview()
            $0.leading.trailing.equalToSuperview()
        }
        
        // Subtitle
        subtitleLabel.snp.makeConstraints {
            $0.top.equalTo(titleLabel.snp.bottom).offset(10)
            $0.leading.trailing.equalToSuperview()
        }
        
        // Selected Hobby Card
        selectedHobbyCard.snp.makeConstraints {
            $0.top.equalTo(subtitleLabel.snp.bottom).offset(24)
            $0.leading.trailing.equalToSuperview()
        }
        
        // CollectionView (정사각형 셀)
        // 셀 크기: (화면 너비 - 20 - 8 - 20) / 2
        let screenWidth = UIScreen.main.bounds.width
        let cellSize = (screenWidth - 20 - 8 - 20) / 2

        collectionView.snp.makeConstraints {
            $0.top.equalTo(selectedHobbyCard.snp.bottom).offset(32)
            $0.leading.trailing.equalToSuperview()
            $0.height.equalTo(cellSize)
        }
    }
}

#Preview {
    PeriodSelectionView()
}