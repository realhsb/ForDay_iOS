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
    case updateRecord(recordId: Int, request: DTO.UpdateRecordRequest)
    case deleteRecord(recordId: Int)
    case addReaction(recordId: Int, reactionType: ReactionType)
    case deleteReaction(recordId: Int, reactionType: ReactionType)
    case fetchReactionUsers(recordId: Int, reactionType: ReactionType, lastUserId: String?, size: Int)
}

extension RecordsTarget: BaseTargetType {

    var path: String {
        switch self {
        case .fetchRecordDetail(let recordId):
            return RecordsAPI.fetchRecordDetail(recordId).endpoint
        case .updateRecord(let recordId, _):
            return RecordsAPI.updateRecord(recordId: recordId).endpoint
        case .deleteRecord(let recordId):
            return RecordsAPI.deleteRecord(recordId).endpoint
        case .addReaction(let recordId, _):
            return RecordsAPI.addReaction(recordId: recordId).endpoint
        case .deleteReaction(let recordId, _):
            return RecordsAPI.deleteReaction(recordId: recordId).endpoint
        case .fetchReactionUsers(let recordId, _, _, _):
            return RecordsAPI.fetchReactionUsers(recordId: recordId).endpoint
        }
    }

    var method: Moya.Method {
        switch self {
        case .fetchRecordDetail:
            return .get
        case .updateRecord:
            return .put
        case .deleteRecord:
            return .delete
        case .addReaction:
            return .post
        case .deleteReaction:
            return .delete
        case .fetchReactionUsers:
            return .get
        }
    }

    var task: Moya.Task {
        switch self {
        case .fetchRecordDetail:
            return .requestPlain
        case .updateRecord(_, let request):
            return .requestJSONEncodable(request)
        case .deleteRecord:
            return .requestPlain
        case .addReaction(_, let reactionType):
            let request = DTO.AddReactionRequest(reactionType: reactionType.rawValue)
            return .requestJSONEncodable(request)
        case .deleteReaction(_, let reactionType):
            return .requestParameters(
                parameters: ["reactionType": reactionType.rawValue],
                encoding: URLEncoding.queryString
            )
        case .fetchReactionUsers(_, let reactionType, let lastUserId, let size):
            var parameters: [String: Any] = [
                "reactionType": reactionType.rawValue,
                "size": size
            ]

            if let lastUserId = lastUserId {
                parameters["lastUserId"] = lastUserId
            }

            return .requestParameters(
                parameters: parameters,
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
