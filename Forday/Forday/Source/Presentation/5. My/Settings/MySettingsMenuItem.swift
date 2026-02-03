//
//  MySettingsMenuItem.swift
//  Forday
//
//  Created by Subeen on 2/3/26.
//

import UIKit

enum MySettingsMenuItem: CaseIterable, DropdownMenuItem {
    case profileSettings
    case hobbyPhotoManagement
    case generalSettings
    case logout

    var title: String {
        switch self {
        case .profileSettings:
            return "내 프로필 설정"
        case .hobbyPhotoManagement:
            return "취미 대표사진 관리"
        case .generalSettings:
            return "전체설정"
        case .logout:
            return "로그아웃"
        }
    }

    var textColor: UIColor {
        switch self {
        case .logout:
            return .systemRed
        default:
            return .neutral800
        }
    }
}
