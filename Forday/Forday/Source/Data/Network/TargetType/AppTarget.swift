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
    case fetchPresignedUrl(request: DTO.PresignedUrlRequest)
    case deleteImage(request: DTO.DeleteImageRequest)
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
        case .deleteImage:
            return AppAPI.deleteImage.endpoint
        }
    }
    
    var method: Moya.Method {
        switch self {
        case .fetchAppMetadata:
            return .get
        case .fetchPresignedUrl:
            return .post
        case .deleteImage:
            return .delete
        }
    }
    
    var task: Moya.Task {
        switch self {
        case .fetchAppMetadata:
            return .requestPlain
        case .fetchPresignedUrl(let request):
            return .requestJSONEncodable(request)
        case .deleteImage(let request):
            let encoder = JSONEncoder()
            encoder.outputFormatting = .withoutEscapingSlashes
            return .requestCustomJSONEncodable(request, encoder: encoder)
        }
    }
}
