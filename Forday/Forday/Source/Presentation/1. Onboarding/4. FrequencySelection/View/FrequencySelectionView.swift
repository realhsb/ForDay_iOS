//
//  FrequencySelectionView.swift
//  Forday
//
//  Created by Subeen on 1/7/26.
//


import UIKit
import SnapKit
import Then

class FrequencySelectionView: UIView {
    
    // Properties
    
//    private let scrollView = UIScrollView()
    private let contentView = UIView()
    
    let titleLabel = UILabel()
    let subtitleLabel = UILabel()
    let selectedHobbyCard = SelectedHobbyCardView()
    let recommendLabel = UILabel()
    let collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
//        layout.scrollDirection = .horizontal
        layout.minimumInteritemSpacing = 0
        return UICollectionView(frame: .zero, collectionViewLayout: layout)
    }()
    
    // Initialization
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        style()
        layout()
    }

    // Configure

    func configureHobbyCard(icon: UIImage?, title: String, time: String?, purpose: String?) {
        selectedHobbyCard.configure(icon: icon, title: title)
        selectedHobbyCard.updateInfo(time: time, purpose: purpose)
        configureSubtitle(hobbyName: title)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

// Setup

extension FrequencySelectionView {
    private func style() {
        backgroundColor = .systemBackground

        titleLabel.do {
            $0.setTextWithTypography("주 몇 회 하실 거예요?", style: .header20)
            $0.textColor = .neutral900
            $0.numberOfLines = 0
        }

        subtitleLabel.do {
            $0.numberOfLines = 0
        }

        recommendLabel.do {
            $0.setTextWithTypography("추천", style: .body14)
            $0.textColor = .action001
            $0.textAlignment = .center
        }
        
        collectionView.do {
            $0.backgroundColor = .clear
            $0.register(FrequencyButtonCell.self, forCellWithReuseIdentifier: FrequencyButtonCell.identifier)
        }
    }

    private func configureSubtitle(hobbyName: String) {
        let suffix = "를 일주일에 몇 번 할까요?\n(처음에는 작게 시작해도 좋아요! 언제든지 변경 가능해요.)"
        let fullText = hobbyName + suffix

        let attributed = NSMutableAttributedString(string: fullText)

        let fullRange = NSRange(location: 0, length: fullText.utf16.count)
        attributed.addAttributes(TypographyStyle.label14.attributes, range: fullRange)
        attributed.addAttribute(.foregroundColor, value: UIColor.neutral800, range: fullRange)

        let hobbyRange = NSRange(location: 0, length: hobbyName.utf16.count)
        attributed.addAttribute(.foregroundColor, value: UIColor.secondary003, range: hobbyRange)

        subtitleLabel.attributedText = attributed
    }

    private func layout() {
        addSubview(contentView)
        
        contentView.addSubview(titleLabel)
        contentView.addSubview(subtitleLabel)
        contentView.addSubview(selectedHobbyCard)
        contentView.addSubview(recommendLabel)
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
            $0.top.equalToSuperview().offset(48)
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
        
        // Recommend Label
        recommendLabel.snp.makeConstraints {
            $0.top.equalTo(selectedHobbyCard.snp.bottom).offset(40)
            $0.centerX.equalToSuperview()
        }
        
        // CollectionView
        collectionView.snp.makeConstraints {
            $0.top.equalTo(recommendLabel.snp.bottom).offset(2)
            $0.leading.trailing.equalToSuperview()
            $0.height.equalTo(40)
        }
    }
}

#Preview {
    FrequencySelectionView()
}
