//
//  WorkoutRecoveryStore.swift
//  Routee-iOS
//
//  Created by LEESANGYUP on 11/11/26.
//

import CryptoKit
import Foundation

struct WorkoutRecoverySnapshot: Codable {
    struct TrackPoint: Codable {
        let pointIndex: Int
        let latitude: Double
        let longitude: Double
        let altitude: Double
    }

    struct Photo: Codable {
        let id: UUID
        let pointIndex: Int
        let createdAt: Date
        let locationTitle: String?
        let objectKey: String?
        let timelineId: Int64?
    }

    struct CourseRoute: Codable {
        let routeId: Int64
        let name: String
        let sequence: Int
    }

    let activityId: Int64
    let activityTitle: String?
    let startedAt: Date?
    let lastRecordedAt: Date
    let endedAt: Date?
    let elapsedTime: TimeInterval
    let distance: Double
    let maximumAltitude: Double?
    let routePoints: [TrackPoint]
    let photos: [Photo]
    let courseRoutes: [CourseRoute]?
    let mapImageObjectKey: String?
    let coverImageObjectKey: String?
}

struct WorkoutRecoveryStore {
    private let directory: URL

    init?(accountId: String) {
        guard !accountId.isEmpty else { return nil }

        let accountKey = SHA256.hash(data: Data(accountId.utf8))
            .map { String(format: "%02x", $0) }.joined()
        directory = URL.applicationSupportDirectory
            .appending(path: "WorkoutRecovery", directoryHint: .isDirectory)
            .appending(path: accountKey, directoryHint: .isDirectory)
    }

    func load() throws -> WorkoutRecoverySnapshot? {
        guard FileManager.default.fileExists(atPath: snapshotURL.path) else { return nil }

        let data = try Data(contentsOf: snapshotURL)
        return try PropertyListDecoder().decode(WorkoutRecoverySnapshot.self, from: data)
    }

    func save(_ snapshot: WorkoutRecoverySnapshot) throws {
        let encoder = PropertyListEncoder()
        encoder.outputFormat = .binary
        try write(encoder.encode(snapshot), to: snapshotURL)
    }

    func loadPhoto(id: UUID) throws -> Data {
        try Data(contentsOf: photoURL(id: id))
    }

    func savePhoto(_ data: Data, id: UUID) throws {
        try write(data, to: photoURL(id: id))
    }

    func clear() throws {
        guard FileManager.default.fileExists(atPath: directory.path) else { return }
        try FileManager.default.removeItem(at: directory)
    }

    private var snapshotURL: URL {
        directory.appending(path: "workout.plist")
    }

    private func photoURL(id: UUID) -> URL {
        directory.appending(path: "\(id.uuidString).jpg")
    }

    private func write(_ data: Data, to url: URL) throws {
        if !FileManager.default.fileExists(atPath: directory.path) {
            try FileManager.default.createDirectory(at: directory, withIntermediateDirectories: true)
            var directory = directory
            var values = URLResourceValues()
            values.isExcludedFromBackup = true
            try directory.setResourceValues(values)
        }

        try data.write(to: url, options: [.atomic, .completeFileProtectionUntilFirstUserAuthentication])
    }
}
