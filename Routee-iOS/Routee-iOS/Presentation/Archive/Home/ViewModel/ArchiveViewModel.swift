//
//  ArchiveViewModel.swift
//  Routee-iOS
//

import Foundation

@MainActor
final class ArchiveViewModel {

    // MARK: - Properties

    private let archiveRepository: ArchiveRepository
    private let mountainMapItemCount = 33

    // MARK: - Initializer

    init(archiveRepository: ArchiveRepository = DefaultArchiveRepository()) {
        self.archiveRepository = archiveRepository
    }

    // MARK: - Public Methods

    func fetchArchive(year: Int, month: Int) async throws -> [ArchiveModel] {
        try await archiveRepository.getArchive(year: year, month: month)
    }

    func fetchActivityList(date: String) async throws -> ActivityListDateModel {
        try await archiveRepository.getActivityList(date: date)
    }

    func makeMountainMapLevels(from durationMinutes: [Int]) -> [Int] {
        let levels = durationMinutes
            .prefix(mountainMapItemCount)
            .map { mountainLevel(durationMinutes: $0) }

        guard levels.count < mountainMapItemCount else {
            return levels
        }

        return levels + Array(repeating: 0, count: mountainMapItemCount - levels.count)
    }

    func makeDurationMinutes(
        year: Int,
        month: Int,
        records: [ArchiveModel]
    ) -> [Int] {
        let recordsByDay = makeRecordsByDay(records)

        return (1...Self.numberOfDays(year: year, month: month)).map {
            recordsByDay[$0]?.totalDurationMinutes ?? 0
        }
    }

    func makeCalendarDays(
        year: Int,
        month: Int,
        records: [ArchiveModel]
    ) -> [CalendarCellModel] {
        let recordsByDay = makeRecordsByDay(records)

        var days = Array(
            repeating: CalendarCellModel(
                content: .empty,
                recordState: .none,
                coverImageName: nil,
                activityDate: nil
            ),
            count: Self.leadingEmptyCount(year: year, month: month)
        )

        for dayValue in 1...Self.numberOfDays(year: year, month: month) {
            let record = recordsByDay[dayValue]
            days.append(
                CalendarCellModel(
                    content: .day(dayValue),
                    recordState: .init(activityCount: record?.activityCount ?? 0),
                    coverImageName: record?.coverImageUrl,
                    activityDate: record?.activityDate
                )
            )
        }

        return days
    }

    // MARK: - Private Methods

    private func makeRecordsByDay(_ records: [ArchiveModel]) -> [Int: ArchiveModel] {
        var recordsByDay: [Int: ArchiveModel] = [:]
        records.forEach { record in
            guard let day = Self.day(from: record.activityDate) else { return }
            recordsByDay[day] = record
        }

        return recordsByDay
    }

    private func mountainLevel(durationMinutes: Int) -> Int {
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
}
