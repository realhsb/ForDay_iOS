//
//  MyPageHobby.swift
//  Forday
//
//  Created by Subeen on 1/27/26.
//

import Foundation

/// 마이페이지 취미 필터에 표시되는 취미 정보
struct MyPageHobby {
    let hobbyId: Int
    let hobbyName: String
    let thumbnailImageUrl: String
    let status: HobbyStatus
}

/// 마이페이지 취미 목록 조회 결과
struct MyHobbiesResult {
    let inProgressHobbyCount: Int  // Segment "진행 중" 옆에 표시
    let hobbyCardCount: Int        // Segment "취미 카드" 옆에 표시
    let hobbies: [MyPageHobby]     // 필터링용 취미 목록 (진행중 우선, 최신순)
}
