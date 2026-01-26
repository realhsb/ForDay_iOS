//
//  UsersAPI.swift
//  Forday
//
//  Created by Subeen on 1/8/26.
//

enum UsersAPI {
    case nicknameAvailability   /// 닉네임 중복 확인
    case settingNickname        /// 닉네임 설정
    case info                   /// 사용자 정보 조회
    case feeds                  /// 사용자 피드 목록 조회

    var endpoint: String {
        switch self {
        case .nicknameAvailability:
            return "/users/nickname/availability"
        case .settingNickname:
            return "/users/nickname"
        case .info:
            return "/users/info"
        case .feeds:
            return "/users/feeds"
        }
    }
}
