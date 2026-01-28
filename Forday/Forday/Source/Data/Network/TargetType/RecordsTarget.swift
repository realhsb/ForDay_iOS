//
//  RecordsTarget.swift
//  Forday
//
//  Created by Subeen on 1/26/26.
//

import Foundation
import Moya
import Alamofire

enum RecordsTarget {
    case fetchRecordDetail(recordId: Int)
}

extension RecordsTarget: BaseTargetType {

    var path: String {
        switch self {
        case .fetchRecordDetail(let recordId):
            return RecordsAPI.fetchRecordDetail(recordId).endpoint
        }
    }

    var method: Moya.Method {
        switch self {
        case .fetchRecordDetail:
            return .get
        }
    }

    var task: Moya.Task {
        switch self {
        case .fetchRecordDetail:
            return .requestPlain
        }
    }

    var headers: [String : String]? {
        return APIConstants.baseHeader
    }

    var validationType: ValidationType {
        return .successCodes
    }
}
