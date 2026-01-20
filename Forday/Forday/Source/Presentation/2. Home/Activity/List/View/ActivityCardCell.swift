//
//  ActivityCardCell.swift
//  Forday
//
//  Created by Subeen on 1/16/26.
//


import UIKit
import SnapKit
import Then

class ActivityCardCell: UITableViewCell {

    static let identifier = "ActivityCardCell"

    // Height Constants
    static let collapsedHeight: CGFloat = 48
    static let expandedHeight: CGFloat = 48 + 1 + 80 // topSection + separator + collection

    // Top Section (Always Visible)
    private let topSectionView = UIView()
    private let activityStackView = UIStackView()
    private let activityLabel = UILabel()
    private let aiRecommendBadge = UIImageView()
    private let chevronImageView = UIImageView()
    private let editButton = UIButton()
    private let deleteButton = UIButton()

    // Expanded Section (Toggle)
    private let expandedSectionView = UIView()
    private let separatorView = UIView()
    private let stickerCollectionView: UICollectionView

    // State
    private var stickers: [ActivitySticker] = []
    private var isExpanded: Bool = false

    // Callbacks
    var onEditTapped: (() -> Void)?
    var onDeleteTapped: (() -> Void)?

    // Initialization

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        // CollectionView Layout
        let flowLayout = UICollectionViewFlowLayout()
        flowLayout.scrollDirection = .horizontal
        flowLayout.minimumInteritemSpacing = 8
        flowLayout.minimumLineSpacing = 8

        stickerCollectionView = UICollectionView(frame: .zero, collectionViewLayout: flowLayout)

        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupStyle()
        setupLayout()
        setupActions()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        isExpanded = false
        chevronImageView.transform = .identity
        onEditTapped = nil
        onDeleteTapped = nil
    }
}

// Setup

extension ActivityCardCell {
    private func setupStyle() {
        selectionStyle = .none
        backgroundColor = .clear

        // Selected Background View
        let selectedBgView = UIView()
        selectedBgView.backgroundColor = UIColor(red: 0.96, green: 0.96, blue: 0.96, alpha: 1.0) // neutral100
        selectedBgView.layer.cornerRadius = 8
        selectedBackgroundView = selectedBgView

        // Top Section
        topSectionView.do {
            $0.backgroundColor = .clear
        }

        // Activity Stack
        activityStackView.do {
            $0.axis = .horizontal
            $0.spacing = 4
            $0.alignment = .center
        }

        activityLabel.do {
            $0.font = .systemFont(ofSize: 16, weight: .medium)
            $0.textColor = .label
            $0.numberOfLines = 1
        }

        aiRecommendBadge.do {
            $0.image = UIImage(systemName: "sparkles") // TODO: 실제 AI 아이콘으로 교체
            $0.tintColor = .systemOrange
            $0.contentMode = .scaleAspectFit
            $0.isHidden = true
        }

        chevronImageView.do {
            $0.image = UIImage(systemName: "chevron.down")
            $0.tintColor = .systemGray
            $0.contentMode = .scaleAspectFit
        }

        editButton.do {
            $0.setImage(UIImage(systemName: "pencil"), for: .normal)
            $0.tintColor = .systemGray
        }

        deleteButton.do {
            $0.setImage(UIImage(systemName: "trash"), for: .normal)
            $0.tintColor = .systemGray
        }

        // Expanded Section
        expandedSectionView.do {
            $0.backgroundColor = .clear
            $0.clipsToBounds = true
        }

        separatorView.do {
            $0.backgroundColor = .systemGray5
        }

        stickerCollectionView.do {
            $0.backgroundColor = .clear
            $0.showsHorizontalScrollIndicator = false
            $0.register(StickerItemCell.self, forCellWithReuseIdentifier: StickerItemCell.identifier)
            $0.delegate = self
            $0.dataSource = self
        }
    }

    private func setupLayout() {
        contentView.addSubview(topSectionView)
        contentView.addSubview(expandedSectionView)

        // Top Section Subviews
        topSectionView.addSubview(activityStackView)
        topSectionView.addSubview(editButton)
        topSectionView.addSubview(deleteButton)

        activityStackView.addArrangedSubview(activityLabel)
        activityStackView.addArrangedSubview(aiRecommendBadge)
        activityStackView.addArrangedSubview(chevronImageView)

        // Expanded Section Subviews
        expandedSectionView.addSubview(separatorView)
        expandedSectionView.addSubview(stickerCollectionView)

        // Top Section
        topSectionView.snp.makeConstraints {
            $0.top.leading.trailing.equalToSuperview()
            $0.height.equalTo(Self.collapsedHeight)
        }

        // Activity Stack (왼쪽)
        activityStackView.snp.makeConstraints {
            $0.leading.equalToSuperview().offset(16)
            $0.centerY.equalToSuperview()
            $0.trailing.lessThanOrEqualTo(editButton.snp.leading).offset(-8)
        }

        aiRecommendBadge.snp.makeConstraints {
            $0.width.height.equalTo(16)
        }

        chevronImageView.snp.makeConstraints {
            $0.width.height.equalTo(16)
        }

        // Edit Button (오른쪽)
        editButton.snp.makeConstraints {
            $0.trailing.equalTo(deleteButton.snp.leading).offset(-8)
            $0.centerY.equalToSuperview()
            $0.width.height.equalTo(24)
        }

        // Delete Button (오른쪽 끝)
        deleteButton.snp.makeConstraints {
            $0.trailing.equalToSuperview().offset(-16)
            $0.centerY.equalToSuperview()
            $0.width.height.equalTo(24)
        }

        // Expanded Section (하단)
        expandedSectionView.snp.makeConstraints {
            $0.top.equalTo(topSectionView.snp.bottom)
            $0.leading.trailing.equalToSuperview()
            $0.bottom.equalToSuperview()
            $0.height.equalTo(0) // 초기 상태: 닫힘
        }

        separatorView.snp.makeConstraints {
            $0.top.equalToSuperview()
            $0.leading.equalToSuperview().offset(16)
            $0.trailing.equalToSuperview().offset(-16)
            $0.height.equalTo(1)
        }

        stickerCollectionView.snp.makeConstraints {
            $0.top.equalTo(separatorView.snp.bottom)
            $0.leading.equalToSuperview().offset(16)
            $0.trailing.equalToSuperview().offset(-16)
            $0.height.equalTo(80)
            $0.bottom.equalToSuperview()
        }
    }

    private func setupActions() {
        editButton.addTarget(self, action: #selector(editButtonTapped), for: .touchUpInside)
        deleteButton.addTarget(self, action: #selector(deleteButtonTapped), for: .touchUpInside)
    }

    @objc private func editButtonTapped() {
        onEditTapped?()
    }

    @objc private func deleteButtonTapped() {
        onDeleteTapped?()
    }
}

// Configure

extension ActivityCardCell {
    func configure(with activity: Activity, isExpanded: Bool) {
        activityLabel.text = activity.content
        aiRecommendBadge.isHidden = !activity.aiRecommended
        deleteButton.isHidden = !activity.deletable

        stickers = activity.stickers
        stickerCollectionView.reloadData()

        self.isExpanded = isExpanded
        updateExpandedState(animated: false)
    }

    private func updateExpandedState(animated: Bool) {
        let height = isExpanded ? 81 : 0 // separator 1 + collection 80

        expandedSectionView.snp.updateConstraints {
            $0.height.equalTo(height)
        }

        let rotation = isExpanded ? CGAffineTransform(rotationAngle: .pi) : .identity

        if animated {
            UIView.animate(withDuration: 0.3) {
                self.chevronImageView.transform = rotation
                self.layoutIfNeeded()
            }
        } else {
            chevronImageView.transform = rotation
        }
    }
}

// UICollectionViewDataSource

extension ActivityCardCell: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return stickers.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: StickerItemCell.identifier, for: indexPath) as? StickerItemCell else {
            return UICollectionViewCell()
        }

        let sticker = stickers[indexPath.item]
        cell.configure(with: sticker)

        return cell
    }
}

// UICollectionViewDelegateFlowLayout

extension ActivityCardCell: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: 60, height: 60)
    }
}
