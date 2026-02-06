//
//  TermsAPI.swift
//  Forday
//
//  Created by Subeen on 2/7/26.
//

import Moya

enum TermsAPI {
    case fetchTermsOfService      /// 서비스 이용약관 조회
    case fetchPrivacyPolicy       /// 개인정보 처리방침 조회

    var endpoint: String {
        switch self {
        case .fetchTermsOfService:
            return "/terms/service"

        case .fetchPrivacyPolicy:
            return "/terms/privacy"
        }
    }
}
