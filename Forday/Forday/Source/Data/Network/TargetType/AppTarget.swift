//
//  AppTarget.swift
//  Forday
//
//  Created by Subeen on 1/8/26.
//

import Foundation
import Moya
import Alamofire

enum AppTarget {
    case fetchAppMetadata
}

extension AppTarget: BaseTargetType {
    
    var baseURL: URL {
        return URL(string: APIConstants.baseURL)!
    }
    
    var path: String {
        switch self {
        case .fetchAppMetadata:
            return AppAPI.fetchAppMetadata.endpoint
        case .fetchPresignedUrl:
            return AppAPI.fetchPresignedUrl.endpoint
        }
    }
    
    var method: Moya.Method {
        switch self {
        case .fetchAppMetadata:
            return .get
        case .fetchPresignedUrl:
            return .post
        }
    }
    
    var task: Moya.Task {
        switch self {
        case .fetchAppMetadata:
            return .requestPlain
        case .fetchPresignedUrl(let request):
            return .requestJSONEncodable(request)
        }
    }
}
