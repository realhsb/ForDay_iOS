//
//  RecordsAPI.swift
//  Forday
//
//  Created by Subeen on 1/26/26.
//

import Foundation

enum RecordsAPI {
    case fetchRecordDetail(Int)  /// 활동 기록 상세 조회
    case addReaction(recordId: Int)  /// 활동 기록에 반응 추가
    case deleteReaction(recordId: Int)  /// 활동 기록 반응 삭제

    var endpoint: String {
        switch self {
        case .fetchRecordDetail(let recordId):
            return "/records/\(recordId)"
        case .addReaction(let recordId):
            return "/records/\(recordId)/reaction"
        case .deleteReaction(let recordId):
            return "/records/\(recordId)/reaction"
        }
    }
}
