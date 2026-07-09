//
//  ArchiveHomeDummyData.swift
//  Routee-iOS
//

import Foundation

enum ArchiveHomeDummyData {
    static let profile = ProfileModel(
        userName: "관악산 날다람쥐",
        streakNumber: 8,
        pointNumber: 25,
        profileImageName: "profile_img_default",
        joinedDate: "2026-03-12"
    )

    static let dummyCalendarRecordsByMonth: [String: [RecordModel]] = [
        "2026-03": [
            .init(
                activityDate: "2026-03-14",
                totalDurationMinutes: 8,
                activityCount: 8,
                coverImageName: nil
            ),
            .init(
                activityDate: "2026-03-15",
                totalDurationMinutes: 2,
                activityCount: 2,
                coverImageName: "calendar_img_2"
            ),
            .init(
                activityDate: "2026-03-16",
                totalDurationMinutes: 3,
                activityCount: 3,
                coverImageName: "calendar_img_3"
            ),
            .init(
                activityDate: "2026-03-30",
                totalDurationMinutes: 1,
                activityCount: 1,
                coverImageName: nil
            )
        ],
        "2026-04": [
            .init(
                activityDate: "2026-04-03",
                totalDurationMinutes: 1,
                activityCount: 1,
                coverImageName: nil
            ),
            .init(
                activityDate: "2026-04-09",
                totalDurationMinutes: 4,
                activityCount: 4,
                coverImageName: "calendar_img_2"
            ),
            .init(
                activityDate: "2026-04-21",
                totalDurationMinutes: 2,
                activityCount: 2,
                coverImageName: nil
            )
        ],
        "2026-05": [
            .init(
                activityDate: "2026-05-02",
                totalDurationMinutes: 1,
                activityCount: 1,
                coverImageName: "calendar_img_3"
            ),
            .init(
                activityDate: "2026-05-11",
                totalDurationMinutes: 6,
                activityCount: 6,
                coverImageName: nil
            ),
            .init(
                activityDate: "2026-05-27",
                totalDurationMinutes: 2,
                activityCount: 2,
                coverImageName: "calendar_img_2"
            )
        ],
        "2026-06": [
            .init(
                activityDate: "2026-06-05",
                totalDurationMinutes: 3,
                activityCount: 3,
                coverImageName: "calendar_img_3"
            ),
            .init(
                activityDate: "2026-06-14",
                totalDurationMinutes: 1,
                activityCount: 1,
                coverImageName: nil
            ),
            .init(
                activityDate: "2026-06-22",
                totalDurationMinutes: 5,
                activityCount: 5,
                coverImageName: nil
            )
        ],
        "2026-07": [
            .init(
                activityDate: "2026-07-14",
                totalDurationMinutes: 8,
                activityCount: 8,
                coverImageName: nil
            ),
            .init(
                activityDate: "2026-07-15",
                totalDurationMinutes: 2,
                activityCount: 2,
                coverImageName: "calendar_img_2"
            ),
            .init(
                activityDate: "2026-07-16",
                totalDurationMinutes: 3,
                activityCount: 3,
                coverImageName: "calendar_img_3"
            ),
            .init(
                activityDate: "2026-07-30",
                totalDurationMinutes: 1,
                activityCount: 1,
                coverImageName: nil
            )
        ]
    ]

    static let dummyMountainDurationMinutes: [Int] = [
        0, 20, 45, 75, 0, 130, 190, 240, 55, 0, 100,
        180, 181, 5, 61, 120, 121, 0, 32, 144, 200, 15,
        70, 150, 225, 0, 59, 119, 179, 181, 260
    ]
}
