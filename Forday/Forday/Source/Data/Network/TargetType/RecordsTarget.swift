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
    case addReaction(recordId: Int, reactionType: ReactionType)
    case deleteReaction(recordId: Int, reactionType: ReactionType)
}

extension RecordsTarget: BaseTargetType {

    var path: String {
        switch self {
        case .fetchRecordDetail(let recordId):
            return RecordsAPI.fetchRecordDetail(recordId).endpoint
        case .addReaction(let recordId, _):
            return RecordsAPI.addReaction(recordId: recordId).endpoint
        case .deleteReaction(let recordId, _):
            return RecordsAPI.deleteReaction(recordId: recordId).endpoint
        }
    }

    var method: Moya.Method {
        switch self {
        case .fetchRecordDetail:
            return .get
        case .addReaction:
            return .post
        case .deleteReaction:
            return .delete
        }
    }

    var task: Moya.Task {
        switch self {
        case .fetchRecordDetail:
            return .requestPlain
        case .addReaction(_, let reactionType):
            let request = DTO.AddReactionRequest(reactionType: reactionType.rawValue)
            return .requestJSONEncodable(request)
        case .deleteReaction(_, let reactionType):
            return .requestParameters(
                parameters: ["reactionType": reactionType.rawValue],
                encoding: URLEncoding.queryString
            )
        }
    }

    var headers: [String : String]? {
        return APIConstants.baseHeader
    }

    var validationType: ValidationType {
        return .successCodes
    }
}
