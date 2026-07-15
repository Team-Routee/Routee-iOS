//
//  RecordEditResourceModel.swift
//  Routee-iOS
//
//  Created by 김세령 on 7/15/26.
//

import Foundation

struct RecordEditResourceModel {
    let distance: Int
    let durationSec: Int
    let maxElevation: Int
    let mapImageURL: String
    let routes: [RecordEditRoute]
}

struct RecordEditRoute {
    let sequence: Int
    let name: String
}
