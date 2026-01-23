//
//  OnboardingData.swift
//  Forday
//
//  Created by Subeen on 1/13/26.
//

import Foundation

struct OnboardingData: Codable {
    var selectedHobbyCard: HobbyCard?
    var timeMinutes: Int = 0
    var purposes: [String] = []
    var executionCount: Int = 0
    var isDurationSet: Bool = false
}
