//
//  PurposeSelectionViewModel.swift
//  Forday
//
//  Created by Subeen on 1/7/26.
//


import Foundation
import Combine

import Foundation
import Combine

class PurposeSelectionViewModel {

    // Published Properties

    @Published var purposes: [PurposeModel] = []
    @Published var selectedPurpose: PurposeModel?
    @Published var isNextButtonEnabled: Bool = false

    // Coordinator에게 데이터 전달
    var onPurposeSelected: ((String) -> Void)?
    
    // Initialization
    
    init() {
        loadMockData()
    }
    
    // Methods
    
    /// Mock 데이터 로드
    private func loadMockData() {
        purposes = [
            PurposeModel(id: "1", title: "스트레스 해소", subtitle: "마음을 편안하게"),
            PurposeModel(id: "2", title: "성장과 만족감", subtitle: "성취감을 얻기 위해"),
            PurposeModel(id: "3", title: "에너지 회복", subtitle: "기분과 활력을 되찾기 위해"),
            PurposeModel(id: "4", title: "삶의 균형 유지", subtitle: "일 중심이 아닌\n삶과의 균형을 위해")
        ]
    }
    
    /// 목적 선택 (단일 선택)
    func selectPurpose(at index: Int) {
        guard index < purposes.count else { return }

        let purpose = purposes[index]
        selectedPurpose = purpose
        isNextButtonEnabled = true

        // 클로저 호출
        onPurposeSelected?(purpose.title)
    }

    /// 해당 인덱스가 선택되었는지 확인
    func isSelected(at index: Int) -> Bool {
        guard index < purposes.count else { return false }
        let purpose = purposes[index]
        return selectedPurpose?.id == purpose.id
    }
}
