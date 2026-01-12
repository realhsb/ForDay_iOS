//
//  UsersTarget.swift
//  Forday
//
//  Created by Subeen on 1/8/26.
//

import Foundation
import Moya
import Alamofire

enum UsersTarget {
    case nicknameAvailability(nickname: String)
//    case settingNickname(request: DTO.SettingNicknameRequest)  // 나중에 구현
}

extension UsersTarget: BaseTargetType {
    
    var path: String {
        switch self {
        case .nicknameAvailability:
            return UsersAPI.nicknameAvailability.endpoint
//        case .settingNickname:
//            return "/users/nickname"
        }
    }
    
    var method: Moya.Method {
        switch self {
        case .nicknameAvailability:
            return Moya.Method.get
//        case .settingNickname:
//            return .post
        }
    }
    
    var task: Moya.Task {
        switch self {
        case .nicknameAvailability(let nickname):

            let parameters = ["nickname": nickname]
            return .requestParameters(parameters: parameters, encoding: URLEncoding.default)
//        case .settingNickname(let request):
//            return .requestJSONEncodable(request)
        }
    }
    
    
}
