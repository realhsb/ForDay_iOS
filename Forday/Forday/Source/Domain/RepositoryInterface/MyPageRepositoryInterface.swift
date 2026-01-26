//
//  MyPageRepositoryInterface.swift
//  Forday
//
//  Created by Subeen on 1/23/26.
//

import Foundation

protocol MyPageRepositoryInterface {
    func fetchUserInfo() async throws -> UserInfo
    func fetchMyActivities(hobbyId: Int?, lastRecordId: Int?, size: Int) async throws -> MyActivitiesResult
    func fetchMyHobbies() async throws -> MyHobbiesResult
    func fetchActivityDetail(activityRecordId: Int) async throws -> ActivityDetail
    func updateProfile(nickname: String, profileImageUrl: String) async throws -> UserInfo
}
