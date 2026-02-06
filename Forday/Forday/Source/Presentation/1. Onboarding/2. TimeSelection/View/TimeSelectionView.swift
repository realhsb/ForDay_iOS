//
//  TimeSelectionView.swift
//  Forday
//
//  Created by Subeen on 1/6/26.
//


import UIKit
import SnapKit
import Then

class TimeSelectionView: UIView {
    
    // Properties
    
    private let scrollView = UIScrollView()
    private let contentView = UIView()
    private let hobbyView = UIView()
    
    let titleLabel = UILabel()
    let hobbyLabel = UILabel()
    let subtitleLabel = UILabel()
    let selectedHobbyCard = SelectedHobbyCardView()
    let timeSlider = TimeSliderView()
    
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

extension TimeSelectionView {
    private func style() {
        backgroundColor = .systemBackground

        titleLabel.do {
            $0.text = "한 번에 얼마나 할 수 있나요?"
            $0.applyTypography(.header20)
            $0.textColor = .neutral900
            $0.numberOfLines = 0
        }

        subtitleLabel.do {
            $0.applyTypography(.label14)
            $0.textColor = .neutral800
            $0.numberOfLines = 0
        }

        hobbyView.do {
            $0.backgroundColor = .bg001
        }
    }

    // Configure

    func configureHobbyCard(icon: UIImage?, title: String) {
        selectedHobbyCard.configure(icon: icon, title: title)
        configureSubtitle(hobbyName: title)
    }

    private func configureSubtitle(hobbyName: String) {
        let suffix = "에 투자할 수 있는 시간을 선택해주세요.\n처음엔 짧게 시작하는 게 좋아요. 습관이 되면 자연스럽게 늘어나요!"
        let fullText = hobbyName + suffix

        let attributed = NSMutableAttributedString(string: fullText)

        // Typography 속성 + 기본 색상 적용
        let fullRange = NSRange(location: 0, length: fullText.utf16.count)
        attributed.addAttributes(TypographyStyle.label14.attributes, range: fullRange)
        attributed.addAttribute(.foregroundColor, value: UIColor.neutral800, range: fullRange)

        // 취미명 부분만 .secondary003
        let hobbyRange = NSRange(location: 0, length: hobbyName.utf16.count)
        attributed.addAttribute(.foregroundColor, value: UIColor.secondary003, range: hobbyRange)

        subtitleLabel.attributedText = attributed
    }
    
    private func layout() {
        addSubview(contentView)
        
        contentView.addSubview(titleLabel)
        contentView.addSubview(subtitleLabel)
        contentView.addSubview(selectedHobbyCard)
        contentView.addSubview(hobbyView)
        contentView.addSubview(timeSlider)
        
        // ContentView
        contentView.snp.makeConstraints {
            $0.edges.equalTo(safeAreaLayoutGuide)
            $0.width.equalToSuperview()
        }
        
        // Title
        titleLabel.snp.makeConstraints {
            $0.top.equalToSuperview().offset(48)
            $0.leading.equalToSuperview().offset(20)
            $0.trailing.equalToSuperview().offset(-20)
        }
        
        // Subtitle
        subtitleLabel.snp.makeConstraints {
            $0.top.equalTo(titleLabel.snp.bottom).offset(12)
            $0.leading.equalToSuperview().offset(20)
            $0.trailing.equalToSuperview().offset(-20)
        }
        
        selectedHobbyCard.snp.makeConstraints {
            $0.top.equalTo(subtitleLabel.snp.bottom).offset(24)
            $0.leading.equalToSuperview().offset(20)
            $0.trailing.equalToSuperview().offset(-20)
        }
        
        // Time Slider
        timeSlider.snp.makeConstraints {
            $0.top.equalTo(selectedHobbyCard.snp.bottom).offset(40)
            $0.leading.equalToSuperview().offset(22)
            $0.trailing.equalToSuperview().offset(-22)
        }
    }
}

#Preview {
    TimeSelectionViewController(viewModel: .init())
}
