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
    var rows: [ActivityListRowViewModel] {
        model.items.map {
            ActivityListRowViewModel(
                title: $0.title,
                thumbnailURL: $0.thumbnailUrl.flatMap(URL.init(string:))
            )
        }
    }
    var isCompactHeight: Bool {
        model.items.count <= 2
    }
    var isScrollEnabled: Bool {
        model.items.count > 3
    }
    private var model: ActivityListDateModel

    // MARK: - Initializer

    init(model: ActivityListDateModel) {
        self.model = model
        dateText = model.dateText
    }

    // MARK: - Public Methods

    func record(at index: Int) -> ActivityListModel? {
        guard model.items.indices.contains(index) else { return nil }
        return model.items[index]
    }

    mutating func updateTitle(activityId: Int64, title: String) {
        let items = model.items.map {
            guard $0.activityId == activityId else { return $0 }

            return ActivityListModel(
                activityId: $0.activityId,
                title: title,
                thumbnailUrl: $0.thumbnailUrl
            )
        }

        model = ActivityListDateModel(
            dateText: model.dateText,
            items: items
        )
    }
}
