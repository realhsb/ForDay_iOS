//
//  StoriesTarget.swift
//  Forday
//
//  Created by Subeen on 2/1/26.
//

import Foundation
import Moya
import Alamofire

enum StoriesTarget {
    case fetchTabs                                          /// 소식 탭 조회 (GET /hobbies/stories/tabs)
    case fetchStories(hobbyId: Int?, lastRecordId: Int?, size: Int, keyword: String?)  /// 소식 목록 조회 (GET /records/stories)
}

extension StoriesTarget: BaseTargetType {

    var path: String {
        switch self {
        case .fetchTabs:
            return StoriesAPI.tabs.endpoint
        case .fetchStories:
            return StoriesAPI.stories.endpoint
        }
    }

    var method: Moya.Method {
        switch self {
        case .fetchTabs, .fetchStories:
            return .get
        }
    }

    var task: Moya.Task {
        switch self {
        case .fetchTabs:
            return .requestPlain

        case .fetchStories(let hobbyId, let lastRecordId, let size, let keyword):
            var parameters: [String: Any] = ["size": size]

            if let hobbyId = hobbyId {
                parameters["hobbyId"] = hobbyId
            }
            if let lastRecordId = lastRecordId {
                parameters["lastRecordId"] = lastRecordId
            }
            if let keyword = keyword {
                parameters["keyword"] = keyword
            }

            return .requestParameters(parameters: parameters, encoding: URLEncoding.queryString)
        }
    }
}
