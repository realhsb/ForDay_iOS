//
//  RecordsAPI.swift
//  Forday
//
//  Created by Subeen on 1/26/26.
//

import Foundation

enum RecordsAPI {
    case fetchRecordDetail(Int)  /// 활동 기록 상세 조회

    var endpoint: String {
        switch self {
        case .fetchRecordDetail(let recordId):
            return "/records/\(recordId)"
        }
    }
}
