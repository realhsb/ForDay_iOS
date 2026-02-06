//
//  TermsTarget.swift
//  Forday
//
//  Created by Subeen on 2/7/26.
//

import Foundation
import Moya
import Alamofire

enum TermsTarget {
    case fetchTermsOfService
    case fetchPrivacyPolicy
}

extension TermsTarget: BaseTargetType {

    var baseURL: URL {
        return URL(string: APIConstants.baseURL)!
    }

    var path: String {
        switch self {
        case .fetchTermsOfService:
            return TermsAPI.fetchTermsOfService.endpoint
        case .fetchPrivacyPolicy:
            return TermsAPI.fetchPrivacyPolicy.endpoint
        }
    }

    var method: Moya.Method {
        switch self {
        case .fetchTermsOfService, .fetchPrivacyPolicy:
            return .get
        }
    }

    var task: Moya.Task {
        switch self {
        case .fetchTermsOfService, .fetchPrivacyPolicy:
            return .requestPlain
        }
    }
}
