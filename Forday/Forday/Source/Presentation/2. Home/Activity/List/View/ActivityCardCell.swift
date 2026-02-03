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

    private let cardCellView = UIView()
    private let activityView = UIView()
    private let activityLabel = UILabel()
    private let aiRecommendBadge = UIImageView()
    private let stickerImageView = UIImageView()
    private let stickerNumberLabel = UILabel()
    private let editButton = UIButton()
    private let deleteButton = UIButton()

    // Callbacks
    var onEditTapped: (() -> Void)?
    var onDeleteTapped: (() -> Void)?

    // Initialization

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        // CollectionView Layout
        let flowLayout = UICollectionViewFlowLayout()
        flowLayout.scrollDirection = .horizontal
        flowLayout.minimumInteritemSpacing = 10
        flowLayout.minimumLineSpacing = 10

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
        onEditTapped = nil
        onDeleteTapped = nil
    }

    // MARK: - Configuration

    func configure(with activity: Activity) {
        activityLabel.text = activity.content
        stickerNumberLabel.setTextWithTypography("\(activity.collectedStickerNum)", style: .label12)

        // Show/hide AI badge
        aiRecommendBadge.isHidden = !activity.aiRecommended

        // Show/hide delete button based on deletable flag
        deleteButton.isHidden = !activity.deletable
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
        cardCellView.do {
            $0.backgroundColor = .clear
        }

        // Activity Stack
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
        
        stickerImageView.do {
            $0.image = .My.stickerCountMy
            $0.contentMode = .scaleAspectFit
            $0.frame.size = CGSize(width: 20, height: 20)
        }
        
        stickerNumberLabel.do {
            $0.textColor = .neutral500
        }

        editButton.do {
            $0.setImage(.Icon.edit, for: .normal)
            $0.tintColor = .neutral400
        }

        deleteButton.do {
            $0.setImage(.Icon.trash, for: .normal)
            $0.tintColor = .neutral400
        }
    }

    private func setupLayout() {
        contentView.addSubview(cardCellView)

        // Top Section Subviews
        cardCellView.addSubview(activityView)
        cardCellView.addSubview(editButton)
        cardCellView.addSubview(deleteButton)

        activityView.addSubview(activityLabel)
        activityView.addSubview(aiRecommendBadge)
        activityView.addSubview(stickerImageView)
        activityView.addSubview(stickerNumberLabel)

        // Top Section
        cardCellView.snp.makeConstraints {
            $0.top.leading.trailing.equalToSuperview()
            $0.height.equalTo(Self.collapsedHeight)
        }

        // Activity Stack (왼쪽)
        activityView.snp.makeConstraints {
            $0.leading.equalToSuperview().offset(16)
            $0.centerY.equalToSuperview()
            $0.top.equalToSuperview().offset(8)
            $0.bottom.equalToSuperview().offset(-8)
            $0.trailing.lessThanOrEqualTo(editButton.snp.leading).offset(-8)
        }

        aiRecommendBadge.snp.makeConstraints {
            $0.leading.equalToSuperview()
            $0.centerY.equalToSuperview()
            $0.width.height.equalTo(14)
        }

        activityLabel.snp.makeConstraints {
            $0.centerY.equalToSuperview()
            $0.leading.equalTo(aiRecommendBadge.snp.trailing).offset(4)
        }

        stickerImageView.snp.makeConstraints {
            $0.centerY.equalToSuperview()
            $0.leading.equalTo(activityLabel.snp.trailing).offset(8)
            $0.width.height.equalTo(20)
        }

        stickerNumberLabel.snp.makeConstraints {
            $0.centerY.equalToSuperview()
            $0.leading.equalTo(stickerImageView.snp.trailing).offset(2)
            $0.trailing.lessThanOrEqualToSuperview()
        }

        // Edit Button (오른쪽)
        editButton.snp.makeConstraints {
            $0.trailing.equalTo(deleteButton.snp.leading).offset(-8)
            $0.centerY.equalToSuperview()
            $0.width.height.equalTo(20)
        }

        // Delete Button (오른쪽 끝)
        deleteButton.snp.makeConstraints {
            $0.trailing.equalToSuperview().offset(-16)
            $0.centerY.equalToSuperview()
            $0.width.height.equalTo(20)
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

// UICollectionViewDelegateFlowLayout

extension ActivityCardCell: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: 60, height: 60)
    }
}

#Preview {
    ActivityCardCell()
}
