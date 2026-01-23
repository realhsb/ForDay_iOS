//
//  GenericAPIResponse.swift
//  Forday
//
//  Created by Subeen on 1/23/26.
//

import Foundation

/// Generic API Response that supports optional data field
/// Use this when the backend may return `data: null` for certain cases
struct APIResponse<T: Decodable>: Decodable {
    let status: Int
    let success: Bool
    let data: T?
}
