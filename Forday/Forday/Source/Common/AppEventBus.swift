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

    // MARK: - Events

    /// Published when user profile (nickname, profile image) is updated
    let profileDidUpdate = PassthroughSubject<Void, Never>()

    /// Published when hobbies (cover images, status) are updated
    let hobbiesDidUpdate = PassthroughSubject<Void, Never>()
}
