//
//  AnalyticsTracker.swift
//  Routee-iOS
//
//  Created by LEESANGYUP on 9/3/26.
//

import Mixpanel

enum AnalyticsTracker {
    static func track(_ event: AnalyticsEvent, properties: Properties? = nil) {
        Mixpanel.mainInstance().track(event: event.rawValue, properties: properties)
    }
}
