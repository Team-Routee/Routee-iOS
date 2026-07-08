//
//  ListModel.swift
//  Routee-iOS
//
//  Created by Codex on 7/8/26.
//

import Foundation

struct ListItemModel {
    let title: String
    let imageName: String?
}

struct ListModel {
    let dateText: String
    let items: [ListItemModel]
}
