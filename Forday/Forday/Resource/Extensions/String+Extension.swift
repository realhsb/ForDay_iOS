//
//  String+Extension.swift
//  Forday
//
//  Created by Subeen on 2/3/26.
//

import Foundation

extension String {
    /// Truncates the string to specified max length with ellipsis
    /// - Parameter maxLength: Maximum number of characters before truncation
    /// - Returns: Truncated string with "..." if longer than maxLength, otherwise original string
    func truncated(maxLength: Int) -> String {
        if self.count > maxLength {
            let index = self.index(self.startIndex, offsetBy: maxLength)
            return String(self[..<index]) + "..."
        }
        return self
    }
}
