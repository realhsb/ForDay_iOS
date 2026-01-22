//
//  StickerItemView.swift
//  Forday
//
//  Created by Subeen on 1/23/26.
//

import UIKit
import SnapKit
import Then

final class StickerItemView: UIView {

    // MARK: - UI Components

    private let imageView = UIImageView().then {
        $0.contentMode = .scaleAspectFit
        $0.tintColor = .systemGray4
    }

    // MARK: - Properties

    private var onTap: (() -> Void)?

    // MARK: - Initialization

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
        setupGesture()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Setup

    private func setupUI() {
        addSubview(imageView)

        imageView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
    }

    private func setupGesture() {
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(handleTap))
        addGestureRecognizer(tapGesture)
        isUserInteractionEnabled = true
    }

    @objc private func handleTap() {
        onTap?()
    }

    // MARK: - Configuration

    func configure(with state: StickerState, onTap: @escaping () -> Void) {
        self.onTap = onTap

        switch state {
        case .empty:
            // 회색 빈 스티커
            imageView.image = UIImage(systemName: "circle.fill")
            imageView.tintColor = .systemGray5

        case .todayHighlight:
            // 핑크 외곽선 스티커 (오늘 기록 안 함)
            imageView.image = UIImage(systemName: "circle")
            imageView.tintColor = .systemPink

        case .filled(let stickerFileName):
            // 실제 스티커 이미지
            // TODO: 나중에 파일명으로 이미지 로드
            // 임시로 컬러 원으로 표시
            imageView.image = UIImage(systemName: "circle.fill")
            imageView.tintColor = colorForSticker(stickerFileName)
        }
    }

    private func colorForSticker(_ fileName: String) -> UIColor {
        // TODO: 실제로는 에셋에서 이미지 로드
        // 임시로 파일명 해시로 색상 결정
        let colors: [UIColor] = [.systemYellow, .systemGreen, .systemBlue, .systemOrange, .systemPurple]
        let index = abs(fileName.hashValue) % colors.count
        return colors[index]
    }

    // MARK: - Sticker State

    enum StickerState {
        case empty                      // 회색 빈 스티커
        case todayHighlight             // 핑크 외곽선 (오늘 기록 가능)
        case filled(String)             // 채워진 스티커 (파일명)
    }
}
