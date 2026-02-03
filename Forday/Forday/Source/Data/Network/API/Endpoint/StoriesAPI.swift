//
//  StoriesAPI.swift
//  Forday
//
//  Created by Subeen on 2/1/26.
//

enum StoriesAPI {
    case tabs          /// 소식 탭 정보 조회 (진행 중인 취미)
    case stories       /// 소식 기록 목록 조회

    var endpoint: String {
        switch self {
        case .tabs:
            return "/hobbies/stories/tabs"
        case .stories:
            return "/records/stories"
        }
    }
}
