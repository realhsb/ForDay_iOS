//
//  ManageHobbyCoverView.swift
//  Forday
//
//  Created by Subeen on 1/27/26.
//

import UIKit
import SnapKit
import Then

class ManageHobbyCoverView: UIView {

    // MARK: - Properties

    // Hobby Selection
    let hobbySelectionButton = UIButton()
    let hobbyLabel = UILabel()
    let chevronImageView = UIImageView()

    // Activity Grid
    let collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .vertical
        layout.minimumInteritemSpacing = 8
        layout.minimumLineSpacing = 8

        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.backgroundColor = .systemBackground
        return collectionView
    }()

    // Empty State
    let emptyStateLabel = UILabel()

    // Select Button
    let selectCoverButton = UIButton()

    // MARK: - Initialization

    override init(frame: CGRect) {
        super.init(frame: frame)
        style()
        layout()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

// MARK: - Setup

extension ManageHobbyCoverView {
    private func style() {
        backgroundColor = .systemBackground

        // Hobby Selection Button
        hobbySelectionButton.do {
            $0.backgroundColor = .systemGray6
            $0.layer.cornerRadius = 12
        }

        hobbyLabel.do {
            $0.text = "취미 선택"
            $0.font = .systemFont(ofSize: 16, weight: .medium)
            $0.textColor = .label
        }

        chevronImageView.do {
            $0.image = UIImage(systemName: "chevron.down")
            $0.tintColor = .secondaryLabel
            $0.contentMode = .scaleAspectFit
        }

        // Collection View
        collectionView.do {
            $0.register(ActivityRecordCell.self, forCellWithReuseIdentifier: "ActivityRecordCell")
            $0.showsVerticalScrollIndicator = true
        }

        // Empty State
        emptyStateLabel.do {
            $0.text = "활동 기록이 없습니다"
            $0.font = .systemFont(ofSize: 14, weight: .regular)
            $0.textColor = .secondaryLabel
            $0.textAlignment = .center
            $0.isHidden = true
        }

        // Select Cover Button
        selectCoverButton.do {
            var config = UIButton.Configuration.filled()
            config.title = "완료"
            config.baseBackgroundColor = .label
            config.baseForegroundColor = .systemBackground
            config.cornerStyle = .medium
            config.contentInsets = NSDirectionalEdgeInsets(top: 12, leading: 0, bottom: 12, trailing: 0)

            $0.configuration = config
            $0.isEnabled = false
        }
    }

    private func layout() {
        addSubview(hobbySelectionButton)
        hobbySelectionButton.addSubview(hobbyLabel)
        hobbySelectionButton.addSubview(chevronImageView)

        addSubview(collectionView)
        addSubview(emptyStateLabel)
        addSubview(selectCoverButton)

        // Hobby Selection Button
        hobbySelectionButton.snp.makeConstraints {
            $0.top.equalTo(safeAreaLayoutGuide).offset(20)
            $0.leading.equalToSuperview().offset(20)
            $0.trailing.equalToSuperview().offset(-20)
            $0.height.equalTo(50)
        }

        hobbyLabel.snp.makeConstraints {
            $0.leading.equalToSuperview().offset(16)
            $0.centerY.equalToSuperview()
        }

        chevronImageView.snp.makeConstraints {
            $0.trailing.equalToSuperview().offset(-16)
            $0.centerY.equalToSuperview()
            $0.width.height.equalTo(20)
        }

        // Collection View
        collectionView.snp.makeConstraints {
            $0.top.equalTo(hobbySelectionButton.snp.bottom).offset(20)
            $0.leading.equalToSuperview().offset(20)
            $0.trailing.equalToSuperview().offset(-20)
            $0.bottom.equalTo(selectCoverButton.snp.top).offset(-20)
        }

        // Empty State
        emptyStateLabel.snp.makeConstraints {
            $0.center.equalTo(collectionView)
        }

        // Select Cover Button
        selectCoverButton.snp.makeConstraints {
            $0.leading.equalToSuperview().offset(20)
            $0.trailing.equalToSuperview().offset(-20)
            $0.bottom.equalTo(safeAreaLayoutGuide).offset(-20)
        }
    }
}

// MARK: - Public Methods

extension ManageHobbyCoverView {
    func updateHobbyLabel(_ hobbyName: String) {
        hobbyLabel.text = hobbyName
    }

    func showEmptyState(_ show: Bool) {
        emptyStateLabel.isHidden = !show
        collectionView.isHidden = show
    }
}

// MARK: - ActivityRecordCell

class ActivityRecordCell: UICollectionViewCell {

    // MARK: - Properties

    let imageView = UIImageView()
    let selectionOverlay = UIView()
    let radioButton = UIImageView()

    var isRecordSelected: Bool = false {
        didSet {
            updateSelectionState()
        }
    }

    // MARK: - Initialization

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupViews()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Setup

    private func setupViews() {
        contentView.addSubview(imageView)
        contentView.addSubview(selectionOverlay)
        contentView.addSubview(radioButton)

        imageView.do {
            $0.contentMode = .scaleAspectFill
            $0.clipsToBounds = true
            $0.layer.cornerRadius = 8
            $0.backgroundColor = .systemGray5
        }

        selectionOverlay.do {
            $0.backgroundColor = UIColor.black.withAlphaComponent(0.3)
            $0.layer.cornerRadius = 8
            $0.isHidden = true
        }

        radioButton.do {
            $0.contentMode = .scaleAspectFit
            $0.tintColor = .white
        }

        imageView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }

        selectionOverlay.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }

        radioButton.snp.makeConstraints {
            $0.top.equalToSuperview().offset(8)
            $0.trailing.equalToSuperview().offset(-8)
            $0.width.height.equalTo(24)
        }
    }

    private func updateSelectionState() {
        selectionOverlay.isHidden = !isRecordSelected
        radioButton.image = isRecordSelected ?
            UIImage(systemName: "checkmark.circle.fill") :
            UIImage(systemName: "circle")
    }

    // MARK: - Configuration

    func configure(with imageURL: String, isSelected: Bool) {
        // Load image using Kingfisher or similar
        // For now, just set background color
        self.isRecordSelected = isSelected
        updateSelectionState()

        // TODO: Load image from URL
        // imageView.kf.setImage(with: URL(string: imageURL))
    }
}
