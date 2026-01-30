//
//  OnboardingCompleteView.swift
//  Forday
//
//  Created by Subeen on 1/12/26.
//


import UIKit
import SnapKit
import Then

class OnboardingCompleteView: UIView {

    // Properties

    let titleLabel = UILabel()
    let subtitleLabel = UILabel()
    let collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        layout.minimumLineSpacing = 10
        return UICollectionView(frame: .zero, collectionViewLayout: layout)
    }()
    let pageControl = UIPageControl()
    let startButton = UIButton()

    // Data
    let slideData: [UIImage] = [.OnboardingCard.smile, .OnboardingCard.laugh, .OnboardingCard.angry, .OnboardingCard.sad]
    
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

extension OnboardingCompleteView {
    private func style() {
        backgroundColor = .systemBackground
        
        titleLabel.do {
            $0.text = "포데이를 함께 할 포비들이에요!"
            $0.font = .systemFont(ofSize: 24, weight: .bold)
            $0.textColor = .label
            $0.textAlignment = .center
            $0.numberOfLines = 0
        }
        
        subtitleLabel.do {
            $0.text = "취미 스티커 콜렉션을 꾸며요 채워보세요.\n뿌듯하실걸요?"
            $0.font = .systemFont(ofSize: 14, weight: .regular)
            $0.textColor = .secondaryLabel
            $0.textAlignment = .center
            $0.numberOfLines = 0
        }
        
        collectionView.do {
            $0.backgroundColor = .clear
            $0.isPagingEnabled = false
            $0.showsHorizontalScrollIndicator = false
            $0.decelerationRate = .fast
            $0.delegate = self
            $0.dataSource = self
            $0.register(OnboardingSlideCell.self, forCellWithReuseIdentifier: OnboardingSlideCell.identifier)
        }

        pageControl.do {
            $0.numberOfPages = 4  // 4개의 슬라이드
            $0.currentPage = 0
            $0.pageIndicatorTintColor = .systemGray4
            $0.currentPageIndicatorTintColor = .systemOrange
            $0.isUserInteractionEnabled = false
        }
        
        startButton.do {
            var config = UIButton.Configuration.filled()
            config.title = "포비와 함께 시작하기"
            config.baseBackgroundColor = .systemOrange
            config.baseForegroundColor = .white
            config.cornerStyle = .medium
            config.contentInsets = NSDirectionalEdgeInsets(top: 18, leading: 0, bottom: 18, trailing: 0)
            
            $0.configuration = config
        }
    }
    
    private func layout() {
        addSubview(titleLabel)
        addSubview(subtitleLabel)
        addSubview(collectionView)
        addSubview(pageControl)
        addSubview(startButton)

        // Title
        titleLabel.snp.makeConstraints {
            $0.top.equalTo(safeAreaLayoutGuide).offset(40)
            $0.leading.trailing.equalToSuperview().inset(20)
        }

        // Subtitle
        subtitleLabel.snp.makeConstraints {
            $0.top.equalTo(titleLabel.snp.bottom).offset(12)
            $0.leading.trailing.equalToSuperview().inset(20)
        }

        // CollectionView (슬라이드)
        collectionView.snp.makeConstraints {
            $0.top.equalTo(subtitleLabel.snp.bottom).offset(32)
            $0.leading.trailing.equalToSuperview()
            $0.height.equalTo(280)
        }

        // PageControl
        pageControl.snp.makeConstraints {
            $0.centerX.equalToSuperview()
            $0.top.equalTo(collectionView.snp.bottom).offset(20)
        }

        // Start Button
        startButton.snp.makeConstraints {
            $0.leading.trailing.equalToSuperview().inset(20)
            $0.bottom.equalTo(safeAreaLayoutGuide).offset(-20)
            $0.height.equalTo(56)
        }
    }
}

// UICollectionViewDataSource

extension OnboardingCompleteView: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return slideData.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(
            withReuseIdentifier: OnboardingSlideCell.identifier,
            for: indexPath
        ) as? OnboardingSlideCell else {
            return UICollectionViewCell()
        }

        let data = slideData[indexPath.item]
        cell.configure(image: data)

        return cell
    }
}

// UICollectionViewDelegate

extension OnboardingCompleteView: UICollectionViewDelegate {
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let pageWidth: CGFloat = 240 + 10 // cell width + spacing
        let currentPage = Int((scrollView.contentOffset.x + scrollView.frame.width / 2) / pageWidth)
        pageControl.currentPage = min(max(currentPage, 0), slideData.count - 1)
    }

    func scrollViewWillEndDragging(_ scrollView: UIScrollView, withVelocity velocity: CGPoint, targetContentOffset: UnsafeMutablePointer<CGPoint>) {
        let cellWidth: CGFloat = 240
        let spacing: CGFloat = 10
        let pageWidth = cellWidth + spacing

        let collectionViewWidth = scrollView.frame.width
        let leftInset = (collectionViewWidth - cellWidth) / 2

        let targetX = targetContentOffset.pointee.x
        let offsetX = targetX + leftInset

        var page = round(offsetX / pageWidth)
        page = max(0, min(page, CGFloat(slideData.count - 1)))

        let newTargetX = page * pageWidth - leftInset
        targetContentOffset.pointee.x = newTargetX
    }
}

// UICollectionViewDelegateFlowLayout

extension OnboardingCompleteView: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let width: CGFloat = 240
        let height: CGFloat = 280
        return CGSize(width: width, height: height)
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        // 첫 번째 셀이 화면 중앙에서 시작하도록
        let collectionViewWidth = collectionView.bounds.width
        let cellWidth: CGFloat = 240
        let leftInset = (collectionViewWidth - cellWidth) / 2
        return UIEdgeInsets(top: 0, left: leftInset, bottom: 0, right: leftInset)
    }
}

#Preview {
    OnboardingCompleteView()
}
