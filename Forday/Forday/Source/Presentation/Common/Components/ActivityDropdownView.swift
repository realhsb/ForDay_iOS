//
//  ActivityDropdownView.swift
//  Forday
//
//  Created by Subeen on 1/19/26.
//


import UIKit
import SnapKit
import Then

class ActivityDropdownView: UIView {
    
    // Properties
    
    private let tableView = UITableView()
    
    private var activities: [Activity] = []
    private var selectedIndexPath: IndexPath?
    var onActivitySelected: ((Activity) -> Void)?
    
    // Initialization
    
    init(activities: [Activity]) {
        self.activities = activities
        super.init(frame: .zero)
        style()
        layout()
        setupTableView()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

// Setup

extension ActivityDropdownView {
    private func style() {
        backgroundColor = .systemBackground
        layer.cornerRadius = 12
        layer.shadowColor = UIColor.black.cgColor
        layer.shadowOpacity = 0.12
        layer.shadowOffset = CGSize(width: 0, height: 2)
        layer.shadowRadius = 12
        
        tableView.do {
            $0.backgroundColor = .clear
            $0.separatorStyle = .singleLine
            $0.separatorInset = UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 16)
            $0.isScrollEnabled = true
            $0.bounces = false
            $0.showsVerticalScrollIndicator = false
            $0.clipsToBounds = true
        }
    }
    
    private func layout() {
        addSubview(tableView)
        
        tableView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
    }
    
    private func setupTableView() {
        tableView.delegate = self
        tableView.dataSource = self
        tableView.separatorStyle = .none
        tableView.register(ActivityDropdownCell.self, forCellReuseIdentifier: ActivityDropdownCell.identifier)
    }
}

// Public Methods

extension ActivityDropdownView {
    func show(in parentView: UIView, below sourceView: UIView) {
        parentView.addSubview(self)

        // Calculate actual height based on content (최대 5개까지만 보이고, 6개 이상이면 스크롤)
        let rowHeight: CGFloat = 48
        let maxVisibleRows: CGFloat = 5
        let totalHeight = min(CGFloat(activities.count) * rowHeight, maxVisibleRows * rowHeight)

        self.snp.makeConstraints {
            $0.top.equalTo(sourceView.snp.bottom).offset(8)
            $0.centerX.equalTo(sourceView)
            $0.width.equalTo(sourceView)
            $0.height.equalTo(totalHeight)
        }
        
        // Fade in animation
        alpha = 0
        transform = CGAffineTransform(scaleX: 0.95, y: 0.95)
        
        UIView.animate(withDuration: 0.2, delay: 0, options: .curveEaseOut) {
            self.alpha = 1
            self.transform = .identity
        }
    }
    
    func dismiss() {
        UIView.animate(withDuration: 0.15, delay: 0, options: .curveEaseIn, animations: {
            self.alpha = 0
            self.transform = CGAffineTransform(scaleX: 0.95, y: 0.95)
        }) { _ in
            self.removeFromSuperview()
        }
    }
}

// UITableViewDataSource

extension ActivityDropdownView: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return activities.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: ActivityDropdownCell.identifier, for: indexPath) as? ActivityDropdownCell else {
            return UITableViewCell()
        }
        
        let activity = activities[indexPath.row]
        let isSelected = indexPath == selectedIndexPath
        cell.configure(with: activity, isSelected: isSelected)
        
        return cell
    }
}

// UITableViewDelegate

extension ActivityDropdownView: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 48
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        // 이전 선택 셀 해제
        if let previousIndexPath = selectedIndexPath {
            tableView.cellForRow(at: previousIndexPath)?.isSelected = false
        }
        
        // 새로운 선택 셀 업데이트
        selectedIndexPath = indexPath
        
        let selectedActivity = activities[indexPath.row]
        onActivitySelected?(selectedActivity)
    }
}

// MARK: - ActivityDropdownCell

class ActivityDropdownCell: UITableViewCell {
    
    static let identifier = "ActivityDropdownCell"

    private let stackView = UIStackView()
    private let activityLabel = UILabel()
    private let aiRecommendImage = UIImageView()
    private let selectedBackgroundContainerView = UIView()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupUI() {
        backgroundColor = .clear
        selectionStyle = .none
        
        // 선택 배경 뷰 설정
        selectedBackgroundContainerView.do {
            $0.backgroundColor = .neutral100
            $0.layer.cornerRadius = 8
            $0.isHidden = true
        }
        
        stackView.do {
            $0.axis = .horizontal
            $0.spacing = 8
            $0.alignment = .center
        }
        
        activityLabel.do {
            $0.applyTypography(.body14)
            $0.textColor = .neutral500
        }
        
        aiRecommendImage.do {
            $0.contentMode = .scaleAspectFit
        }
        
        contentView.addSubview(selectedBackgroundContainerView)
        contentView.addSubview(stackView)
        
        stackView.addArrangedSubview(aiRecommendImage)
        stackView.addArrangedSubview(activityLabel)
        
        selectedBackgroundContainerView.snp.makeConstraints {
            $0.leading.trailing.equalToSuperview().inset(8)
            $0.top.bottom.equalToSuperview().inset(4)
        }
        
        stackView.snp.makeConstraints {
            $0.centerX.equalToSuperview()
            $0.centerY.equalToSuperview()
        }
        
        aiRecommendImage.snp.makeConstraints {
            $0.width.height.equalTo(20)
        }
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        updateSelectionUI(selected: selected)
    }
    
    private func updateSelectionUI(selected: Bool) {
        if selected {
            selectedBackgroundContainerView.isHidden = false
            activityLabel.applyTypography(.header14)
            activityLabel.textColor = .neutral800
        } else {
            selectedBackgroundContainerView.isHidden = true
            activityLabel.applyTypography(.body14)
            activityLabel.textColor = .neutral500
        }
    }
    
    func configure(with activity: Activity, isSelected: Bool) {
        activityLabel.text = activity.content

        if activity.aiRecommended {
            aiRecommendImage.image = .Ai.small
            aiRecommendImage.isHidden = false
        } else {
            aiRecommendImage.isHidden = true
        }
        
        // 선택 상태 적용
        updateSelectionUI(selected: isSelected)
    }
}

#Preview {
    let activities = [
        Activity(activityId: 1, content: "미라클 모닝 아침 독서", aiRecommended: false, deletable: false, stickers: []),
        Activity(activityId: 2, content: "한 챕터마다 독후감 쓰기", aiRecommended: false, deletable: true, stickers: []),
        Activity(activityId: 3, content: "SNS 독서 인증", aiRecommended: true, deletable: true, stickers: [])
    ]
    return ActivityDropdownView(activities: activities)
}
