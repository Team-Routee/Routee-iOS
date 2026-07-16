//
//  CalendarCellModel.swift
//  Routee-iOS
//

import Foundation

struct CalendarCellModel {

    enum Content {
        case empty
        case day(Int)
    }

    enum RecordState {
        case none
        case single
        case multiple(Int)
    }

    let content: Content
    let recordState: RecordState
    let coverImageUrl: String?
    let activityDate: String?
}

extension CalendarCellModel.RecordState {

    init(activityCount: Int) {
        if activityCount == 0 {
            self = .none
        } else if activityCount == 1 {
            self = .single
        } else {
            self = .multiple(min(activityCount, 9))
        }
    }
}
