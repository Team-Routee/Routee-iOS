//
//  Date+.swift
//  Routee-iOS
//
//  Created by 김세령 on 7/7/26.
//

import UIKit

extension Date {
    var startOfMonth: Date {
        let calendar = Calendar.current
        let components = calendar.dateComponents([.year, .month], from: self)
        return calendar.date(from: components) ?? self
    }
    
    func isSameMonth(as date: Date) -> Bool {
        let calendar = Calendar.current
        return calendar.component(.year, from: self) == calendar.component(.year, from: date)
        && calendar.component(.month, from: self) == calendar.component(.month, from: date)
    }
    
    static func date(_ year: Int, _ month: Int, _ day: Int) -> Date {
        Calendar.current.date(
            from: DateComponents(year: year, month: month, day: day)
        )!
    }
}
