//
//  calendarModel.swift
//  Routee-iOS
//
//  Created by 초긍정행운의포춘쿠키 on 7/6/26.
//

import UIKit

struct CalendarDayItem {

    enum Content {
        case empty
        case day(Int)
    }

    enum RecordState {
        case none
        case background
        case badge(Int)
    }

    let content: Content
    let recordState: RecordState
    let coverImageName: String?
    let activityDate: String?
}

extension CalendarDayItem.RecordState {

    init(activityCount: Int) {
        if activityCount == 0 {
            self = .none
        } else if activityCount == 1 {
            self = .background
        } else {
            self = .badge(min(activityCount, 9))
        }
    }
}
