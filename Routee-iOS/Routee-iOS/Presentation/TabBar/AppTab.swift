//
//  AppTab.swift
//  Routee-iOS
//
//  Created by LEESANGYUP on 9/4/26.
//

import UIKit

enum AppTab: Int, CaseIterable {
    case workout
    case recordEdit
    case archive
    case setting

    var title: String {
        switch self {
        case .workout: "운동"
        case .recordEdit: "기록 편집"
        case .archive: "아카이브"
        case .setting: "설정"
        }
    }

    var normalImage: UIImage {
        switch self {
        case .workout: .icExerciseNavSmGrey
        case .recordEdit: .icRecapNavSmGrey
        case .archive: .icArchiveNavSmGrey
        case .setting: .icSettingNavSmGrey
        }
    }

    var selectedImage: UIImage {
        switch self {
        case .workout: .icExerciseNavSmWhite
        case .recordEdit: .icRecapNavSmWhite
        case .archive: .icArchiveNavSmWhite
        case .setting: .icSettingNavSmWhite
        }
    }
}

enum TabNavigationResetPolicy {
    case none
    case destination
    case currentAndDestination
}

protocol AppTabRouting: AnyObject {
    func select(
        _ tab: AppTab,
        reset: TabNavigationResetPolicy,
        animated: Bool
    )
}
