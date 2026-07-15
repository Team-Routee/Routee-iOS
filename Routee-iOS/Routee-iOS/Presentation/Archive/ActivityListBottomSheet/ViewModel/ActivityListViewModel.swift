//
//  ActivityListViewModel.swift
//  Routee-iOS
//
//  Created by 초긍정행운의포춘쿠키 on 7/15/26.
//

import Foundation

struct ActivityListRowViewModel {
    let title: String
    let thumbnailURL: URL?
}

struct ActivityListViewModel {

    // MARK: - Properties

    let dateText: String
    let rows: [ActivityListRowViewModel]
    let isCompactHeight: Bool
    let isScrollEnabled: Bool
    private let model: ActivityListDateModel

    // MARK: - Initializer

    init(model: ActivityListDateModel) {
        self.model = model
        dateText = model.dateText
        rows = model.items.map {
            ActivityListRowViewModel(
                title: $0.title,
                thumbnailURL: $0.thumbnailUrl.flatMap(URL.init(string:))
            )
        }
        isCompactHeight = model.items.count <= 2
        isScrollEnabled = model.items.count > 3
    }

    // MARK: - Public Methods

    func record(at index: Int) -> ActivityListModel? {
        guard model.items.indices.contains(index) else { return nil }
        return model.items[index]
    }
}
