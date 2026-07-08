//
//  ArchiveListDummyData.swift
//  Routee-iOS
//
//  Created by Codex on 7/8/26.
//

import Foundation

enum ArchiveListDummyData {

    static let defaultModel = ListModel(
        dateText: "2026.07.08",
        items: makeItems(count: 4)
    )

    static func makeModel(
        dateText: String = "2026.07.08",
        count: Int
    ) -> ListModel {
        .init(
            dateText: dateText,
            items: makeItems(count: count)
        )
    }

    private static func makeItems(count: Int) -> [ListItemModel] {
        let source: [ListItemModel] = [
            .init(title: "숭실대 동기모임 북한산", imageName: nil),
            .init(title: "백석동천 저녁 산책", imageName: "img_location1"),
            .init(title: "성곽주변 저녁 러닝", imageName: "img_location4"),
            .init(title: "한강 새벽 러닝", imageName: "img_location1"),
            .init(title: "관악산 아침 산책", imageName: nil)
        ]

        guard count > 0 else { return [] }
        if count <= source.count {
            return Array(source.prefix(count))
        }

        var items = source
        while items.count < count {
            let index = items.count % source.count
            items.append(source[index])
        }
        return items
    }
}
