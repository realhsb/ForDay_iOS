//
//  NicknameViewModel.swift
//  Forday
//
//  Created by Subeen on 1/9/26.
//


import Foundation
import Combine

class NicknameViewModel {
    
    // Published Properties
    
    @Published var nickname: String = ""
    @Published var validationResult: NicknameValidationResult = .empty
    @Published var isDuplicateChecked: Bool = false
    @Published var isNextButtonEnabled: Bool = false
    
    private var cancellables = Set<AnyCancellable>()
    
    // UseCase
    private let checkNicknameDuplicateUseCase: CheckNicknameDuplicateUseCase
    
    // Initialization
    
    init(checkNicknameDuplicateUseCase: CheckNicknameDuplicateUseCase = CheckNicknameDuplicateUseCase()) {
        self.checkNicknameDuplicateUseCase = checkNicknameDuplicateUseCase
        bind()
    }
    
    // Methods
    
    private func bind() {
        // 닉네임 변경 시 자동 유효성 검사
        $nickname
            .sink { [weak self] text in
                self?.validateNickname(text)
            }
            .store(in: &cancellables)
        
        // 중복 확인 완료 시 다음 버튼 활성화
        $isDuplicateChecked
            .combineLatest($validationResult)
            .sink { [weak self] isChecked, result in
                // 중복 확인 완료 + 에러 없음
                self?.isNextButtonEnabled = isChecked && result == .valid
            }
            .store(in: &cancellables)
    }
    
    /// 닉네임 유효성 검사 (클라이언트 검증)
    private func validateNickname(_ text: String) {
        // 닉네임 변경 시 중복 확인 리셋
        isDuplicateChecked = false
        
        // 빈 값
        if text.isEmpty {
            validationResult = .empty
            return
        }
        
        // 한글/영어/숫자만 허용
        let pattern = "^[가-힣a-zA-Z0-9]+$"
        let regex = try? NSRegularExpression(pattern: pattern)
        let range = NSRange(location: 0, length: text.utf16.count)
        
        if regex?.firstMatch(in: text, range: range) == nil {
            validationResult = .invalidCharacters
            return
        }
        
        // 클라이언트 검증 통과
        validationResult = .valid
    }
    
    /// 중복 확인 (서버 통신)
    func checkDuplicate() async {
        // 클라이언트 검증부터 확인
        guard validationResult == .valid else {
            return
        }
        
        print("🔍 중복 확인 시작: \(nickname)")
        
        do {
            let isAvailable = try await checkNicknameDuplicateUseCase.execute(nickname: nickname)
            
            await MainActor.run {
                if isAvailable {
                    // 사용 가능
                    validationResult = .valid
                    isDuplicateChecked = true
                    print("✅ 사용 가능한 닉네임")
                } else {
                    // 중복
                    validationResult = .duplicate
                    isDuplicateChecked = false
                    print("❌ 중복된 닉네임")
                }
            }
        } catch {
            await MainActor.run {
                print("❌ 중복 확인 실패: \(error)")
                // TODO: 에러 처리
            }
        }
    }
}
