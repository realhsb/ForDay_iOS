//
//  HobbySelectionViewModel.swift
//  Forday
//
//  Created by Subeen on 1/5/26.
//


import Foundation
import Combine

class HobbySelectionViewModel {
    
    // MARK: - Published Properties
    
    @Published var hobbies: [HobbyCard] = []
    @Published var selectedHobby: HobbyCard?
    @Published var isNextButtonEnabled: Bool = false
    
    // Coordinator에게 데이터 전달
    var onHobbySelected: ((HobbyCard) -> Void)?
    
    // MARK: - Initialization
    
    init() {
        loadMockData()
    }
    
    // MARK: - Methods
    
    /// Mock 데이터 로드
    private func loadMockData() {
        hobbies = [
            HobbyCard(id: 1, name: "그림 그리기", description: "다양한 도구로 그림 연습하기", imageAsset: .drawing),
            HobbyCard(id: 2, name: "헬스", description: "건강한 몸 만들기", imageAsset: .gym),
            HobbyCard(id: 3, name: "독서", description: "책을 읽으며 생각 넓히기", imageAsset: .reading),
            HobbyCard(id: 4, name: "음악 듣기", description: "좋아하는 스타일의 음악 듣기", imageAsset: .music),
            HobbyCard(id: 5, name: "러닝", description: "목표 거리를 정해 달리기", imageAsset: .running),
            HobbyCard(id: 6, name: "요리", description: "맛있는 음식 직접 만들기", imageAsset: .cooking),
            HobbyCard(id: 7, name: "카페 탐방", description: "다양한 카페를 직접 방문", imageAsset: .cafe),
            HobbyCard(id: 8, name: "영화 보기", description: "좋아하는 영화 보며 힐링", imageAsset: .movie),
            HobbyCard(id: 9, name: "사진 촬영", description: "일상의 순간을 예술로", imageAsset: .photo),
            HobbyCard(id: 10, name: "글쓰기", description: "나를 들여다보는 글쓰기", imageAsset: .writing)
        ]
    }
    
    /// 취미 선택
    func selectHobby(at index: Int) {
        guard index < hobbies.count else { return }
        
        let hobby = hobbies[index]
        
        // 같은 취미를 다시 선택하면 선택 해제
        if selectedHobby?.id == hobby.id {
            selectedHobby = nil
            isNextButtonEnabled = false
        } else {
            selectedHobby = hobby
            isNextButtonEnabled = true
        }
        
        // 클로저 호출
        if let selectedHobby = selectedHobby {
            onHobbySelected?(selectedHobby)
        }
    }
    
    /// 커스텀 취미 추가
    func addCustomHobby(_ title: String) {
        let customHobby = HobbyCard(
            id: nil,
            name: title,
            description: "나만의 취미",
            imageAsset: .drawing  // 기본 이미지
        )
        hobbies.append(customHobby)
        selectedHobby = customHobby
        isNextButtonEnabled = true
        
        // 클로저 호출
        onHobbySelected?(customHobby)
    }
    
    /// 선택된 취미인지 확인
    func isSelected(at index: Int) -> Bool {
        guard index < hobbies.count else { return false }
        return hobbies[index].id == selectedHobby?.id
    }
}
