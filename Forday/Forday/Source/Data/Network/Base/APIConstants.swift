//
//  APIConstants.swift
//  Forday
//
//  Created by Subeen on 1/8/26.
//

import Foundation

struct APIConstants {
    static let baseURL: String = {
        guard let url = Bundle.main.infoDictionary?["BASE_URL"] as? String else {
            fatalError("BASE_URL not found in Info.plist")
        }
        return url
    }()
    static let contentType = "Content-Type"
    static let applicationJson = "application/json"
}

extension APIConstants {
    static var baseHeader: Dictionary<String, String> {
        [
            contentType : applicationJson
        ]
    }
}
