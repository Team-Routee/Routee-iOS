//
//  ArchiveDummyData.swift
//  Routee-iOS
//
//  Created by Codex on 7/8/26.
//

import Foundation

struct ArchiveCalendarDummyModel {
    let activityDate: String
    let totalDurationMinutes: Int
    let activityCount: Int
    let coverImageName: String?
}

enum ArchiveDummyData {

    private enum Metric {
        static let mountainMapItemCount = 33
    }

    static let profile = ProfileModel(
        userName: "관악산 날다람쥐",
        streakNumber: 8,
        pointNumber: 25,
        profileImageName: "profile_img_default",
        joinedDate: "2026-03-12"
    )

    static func dummyCalendarRecords(year: Int, month: Int) -> [ArchiveCalendarDummyModel] {
        [
            .init(
                activityDate: "\(year)-\(twoDigits(month))-14",
                totalDurationMinutes: 8,
                activityCount: 8,
                coverImageName: nil
            ),
            .init(
                activityDate: "\(year)-\(twoDigits(month))-15",
                totalDurationMinutes: 2,
                activityCount: 2,
                coverImageName: "calendar_img_2"
            ),
            .init(
                activityDate: "\(year)-\(twoDigits(month))-16",
                totalDurationMinutes: 3,
                activityCount: 3,
                coverImageName: "calendar_img_3"
            ),
            .init(
                activityDate: "\(year)-\(twoDigits(month))-30",
                totalDurationMinutes: 1,
                activityCount: 1,
                coverImageName: nil
            )
        ]
    }

    static let dummyMountainDurationMinutes: [Int] = [
        0, 20, 45, 75, 0, 130, 190, 240, 55, 0, 100,
        180, 181, 5, 61, 120, 121, 0, 32, 144, 200, 15,
        70, 150, 225, 0, 59, 119, 179, 181, 260
    ]

    static func monthTitle(year: Int, month: Int) -> String {
        "\(year)년 \(month)월"
    }

    static func calendarDays(year: Int, month: Int) -> [CalendarModel] {
        let recordsByDay = Dictionary(
            uniqueKeysWithValues: dummyCalendarRecords(year: year, month: month).compactMap {
                record -> (Int, ArchiveCalendarDummyModel)? in
                guard let dayValue = day(from: record.activityDate) else { return nil }
                return (dayValue, record)
            }
        )

        var days = Array(
            repeating: CalendarModel(
                content: .empty,
                recordState: .none,
                coverImageName: nil,
                activityDate: nil
            ),
            count: leadingEmptyCount(year: year, month: month)
        )

        for dayValue in 1...numberOfDays(year: year, month: month) {
            let record = recordsByDay[dayValue]
            days.append(
                CalendarModel(
                    content: .day(dayValue),
                    recordState: .init(activityCount: record?.activityCount ?? 0),
                    coverImageName: record?.coverImageName,
                    activityDate: record?.activityDate
                )
            )
        }

        return days
    }

    static func mountainLevels(year: Int, month: Int) -> [Int] {
        let levels = dummyMountainDurationMinutes
            .prefix(Metric.mountainMapItemCount)
            .map { mountainLevel(durationMinutes: $0) }

        guard levels.count < Metric.mountainMapItemCount else {
            return levels
        }

        return levels + Array(repeating: 0, count: Metric.mountainMapItemCount - levels.count)
    }

    static func canMoveToPreviousMonth(year: Int, month: Int) -> Bool {
        monthStart(year: year, month: month) > monthStart(from: profile.joinedDate)
    }

    static func canMoveToNextMonth(year: Int, month: Int) -> Bool {
        monthStart(year: year, month: month) < monthStart(from: Date())
    }

    private static func twoDigits(_ value: Int) -> String {
        String(format: "%02d", value)
    }

    private static func day(from activityDate: String) -> Int? {
        Int(activityDate.split(separator: "-").last ?? "")
    }

    private static func leadingEmptyCount(year: Int, month: Int) -> Int {
        var components = DateComponents()
        components.year = year
        components.month = month
        components.day = 1

        guard let date = Calendar.current.date(from: components) else { return 0 }

        let weekday = Calendar.current.component(.weekday, from: date)
        return (weekday + 5) % 7
    }

    private static func numberOfDays(year: Int, month: Int) -> Int {
        var components = DateComponents()
        components.year = year
        components.month = month

        guard
            let date = Calendar.current.date(from: components),
            let range = Calendar.current.range(of: .day, in: .month, for: date)
        else { return 30 }

        return range.count
    }

    private static func mountainLevel(durationMinutes: Int) -> Int {
        switch durationMinutes {
        case ...0:
            return 0
        case 1...60:
            return 1
        case 61...120:
            return 2
        case 121...180:
            return 3
        default:
            return 4
        }
    }

    private static func monthStart(from joinedDate: String) -> Date {
        let formatter = DateFormatter()
        formatter.calendar = Calendar(identifier: .gregorian)
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.dateFormat = "yyyy-MM-dd"

        let date = formatter.date(from: joinedDate) ?? Date()
        return monthStart(from: date)
    }

    private static func monthStart(from date: Date) -> Date {
        let components = Calendar.current.dateComponents([.year, .month], from: date)
        return Calendar.current.date(from: components) ?? date
    }

    private static func monthStart(year: Int, month: Int) -> Date {
        var components = DateComponents()
        components.year = year
        components.month = month
        components.day = 1

        return Calendar.current.date(from: components) ?? Date()
    }
}
