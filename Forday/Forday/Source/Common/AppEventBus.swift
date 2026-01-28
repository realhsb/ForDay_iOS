//
//  AppEventBus.swift
//  Forday
//
//  Created by Subeen on 1/28/26.
//

import Foundation
import Combine

/// Central event bus for app-wide events using Combine
final class AppEventBus {

    /// Shared singleton instance
    static let shared = AppEventBus()

    private init() {}

    // MARK: - User Profile Events

    /// Published when user profile (nickname, profile image) is updated
    let profileDidUpdate = PassthroughSubject<Void, Never>()

    // MARK: - Hobby Events

    /// Published when hobbies (cover images, status) are updated
    let hobbiesDidUpdate = PassthroughSubject<Void, Never>()

    /// Published when hobby settings (time, frequency, goal days) are updated
    /// Payload: hobbyId of the updated hobby
    let hobbySettingsUpdated = PassthroughSubject<Int, Never>()

    /// Published when a new hobby is created
    /// Payload: hobbyId of the new hobby
    let hobbyCreated = PassthroughSubject<Int, Never>()

    /// Published when a hobby is deleted or archived
    let hobbyDeleted = PassthroughSubject<Void, Never>()

    // MARK: - Activity Record Events

    /// Published when a new activity record is created
    /// Payload: hobbyId that the activity belongs to
    let activityRecordCreated = PassthroughSubject<Int, Never>()

    /// Published when an activity record is deleted
    let activityRecordDeleted = PassthroughSubject<Void, Never>()
}
