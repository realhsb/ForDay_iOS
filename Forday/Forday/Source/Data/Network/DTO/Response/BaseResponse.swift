//
//  BaseResponse.swift
//  Forday
//
//  Created by Subeen on 1/8/26.
//

protocol BaseResponse: Codable {
    associatedtype DataType: Codable
    var status: Int { get }
    var success: Bool { get }
    var data: DataType { get }
}
