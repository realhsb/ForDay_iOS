//
//  TimeSelectionViewModel.swift
//  Forday
//
//  Created by Subeen on 1/6/26.
//


import Foundation
import Combine

class TimeSelectionViewModel {
    
    // Published Properties
    
    @Published var selectedTime: String?
    @Published var isNextButtonEnabled: Bool = false
    
    // Coordinator에게 데이터 전달
    var onTimeSelected: ((Int) -> Void)?
    
    // Methods
    
    func selectTime(_ time: String) {
        selectedTime = time
        isNextButtonEnabled = true
    }
}
