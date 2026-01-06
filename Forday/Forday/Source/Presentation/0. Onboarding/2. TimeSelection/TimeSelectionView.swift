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
    
    let titleLabel = UILabel()
    
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
            $0.text = "취미 시간 선택 (임시)"
            $0.font = .systemFont(ofSize: 24, weight: .bold)
            $0.textColor = .label
            $0.textAlignment = .center
        }
    }
    
    private func layout() {
        addSubview(titleLabel)
        
        titleLabel.snp.makeConstraints {
            $0.center.equalToSuperview()
        }
    }
}