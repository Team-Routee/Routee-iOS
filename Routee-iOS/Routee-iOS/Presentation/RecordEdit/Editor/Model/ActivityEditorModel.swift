//
//  ActivityEditorModel.swift
//  Routee-iOS
//
//  Created by 김세령 on 7/15/26.
//

import Foundation

struct ActivityEditorModel {
    let activityId: Int64
    let trackPoints: [TrackPoint]
    let pointIndices: [Int]
    let timelineMarkers: [ActivityRouteMarkerModel]
}
