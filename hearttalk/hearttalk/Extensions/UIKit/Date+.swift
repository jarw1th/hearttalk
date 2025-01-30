//
//  Date+.swift
//  hearttalk
//
//  Created by Руслан Парастаев on 31.01.2025.
//

import Foundation

extension Date {
    
    func isMoreHour() -> Bool {
        let calendar = Calendar.current
        let date1 = Date()
        let date2 = self

        let difference = date1.timeIntervalSince(date2)
        return difference > 3600
    }
    
}
