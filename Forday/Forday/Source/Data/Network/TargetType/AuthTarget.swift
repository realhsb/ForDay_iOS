//
//  AuthTarget.swift
//  Forday
//
//  Created by Subeen on 1/8/26.
//

import Foundation
import Moya
import Alamofire

enum AuthTarget {
    case kakaoLogin(request: DTO.KakaoLoginRequest)
    case appleLogin(request: DTO.AppleLoginRequest)
    case guestLogin(request: DTO.GuestLoginRequest)
    case refreshToken(request: DTO.TokenRefreshRequest)
    case validateToken
    case switchAccount(request: DTO.SwitchAccountRequest)
//    case logout
}

extension AuthTarget: BaseTargetType {

    var baseURL: URL {
        return URL(string: APIConstants.baseURL)!
    }

    var path: String {
        switch self {
        case .kakaoLogin:
            return AuthAPI.kakaoLogin.endpoint
        case .appleLogin:
            return AuthAPI.appleLogin.endpoint
        case .guestLogin:
            return AuthAPI.guestLogin.endpoint
        case .refreshToken:
            return AuthAPI.refreshToken.endpoint
        case .validateToken:
            return AuthAPI.authValidate.endpoint
        case .switchAccount:
            return AuthAPI.switchAccount.endpoint
//        case .logout:
//            return AuthAPI.logout.endpoint
        }
    }

    var method: Moya.Method {
        switch self {
        case .kakaoLogin, .appleLogin, .guestLogin, .refreshToken /*, .logout*/:
            return .post
        case  .switchAccount:
            return .patch
        case .validateToken:
            return .get
        }
    }

    var task: Moya.Task {
        switch self {
        case .kakaoLogin(let request):
            return .requestJSONEncodable(request)
        case .appleLogin(let request):
            return .requestJSONEncodable(request)
        case .guestLogin(let request):
            return .requestJSONEncodable(request)
        case .refreshToken(let request):
            return .requestJSONEncodable(request)
        case .switchAccount(let request):
            return .requestJSONEncodable(request)
        case .validateToken:
            return .requestPlain
//        case .logout:
//            return .requestPlain
        }
    }

    var headers: [String: String]? {
        var headers = ["Content-Type": "application/json"]

        // switchAccount, validateToken은 인증 토큰 필요
        switch self {
        case .switchAccount, .validateToken:
            if let token = try? TokenStorage.shared.loadAccessToken() {
                headers["Authorization"] = "Bearer \(token)"
            }
        default:
            break
        }

        return headers
    }
}
