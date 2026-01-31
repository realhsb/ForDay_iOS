//
//  MyPageRepositoryInterface.swift
//  Forday
//
//  Created by Subeen on 1/23/26.
//

import Foundation

protocol MyPageRepositoryInterface {
    func fetchUserInfo() async throws -> UserInfo
    func fetchMyHobbies() async throws -> MyHobbiesResult
    func fetchActivityDetail(activityRecordId: Int) async throws -> ActivityDetail
    func updateProfile(nickname: String, profileImageUrl: String) async throws -> UserInfo
    func addReaction(recordId: Int, reactionType: ReactionType) async throws -> AddReactionResult
    func deleteReaction(recordId: Int, reactionType: ReactionType) async throws -> DeleteReactionResult
    func fetchReactionUsers(recordId: Int, reactionType: ReactionType, lastUserId: String?, size: Int) async throws -> FetchReactionUsersResult
}
