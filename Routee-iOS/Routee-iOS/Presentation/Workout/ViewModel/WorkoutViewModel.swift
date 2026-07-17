//
//  WorkoutViewModel.swift
//  Routee-iOS
//
//  Created by LEESANGYUP on 7/9/26.
//

import CoreLocation
import UIKit

final class WorkoutViewModel {
    var elapsedTimeDidChange: ((TimeInterval) -> Void)?
    var maximumAltitudeDidChange: ((CLLocationDistance?) -> Void)?
    var elapsedTimeInSeconds: Int {
        max(0, Int(currentElapsedTime))
    }
    private(set) var maximumAltitudeInMeters: CLLocationDistance?
    private(set) var routePoints: [WorkoutRoutePoint] = []
    private(set) var photoRecords: [WorkoutPhotoRecord] = []

    var canFinishRecording: Bool {
        routePoints.count > 1
    }
    private(set) var activityId: Int64?
    private(set) var activityTitle: String?
    private(set) var backgroundMapImageURL: String?
    private(set) var coverImageObjectKey: String?
    
    private let reverseGeocodingRepository: ReverseGeocodingRepository
    private let activityRepository: ActivityRepository
    private var lastReverseGeocodingLocation: CLLocation?
    private var lastRecordedLocation: CLLocation?
    private(set) var totalDistance: CLLocationDistance = 0
    private var elapsedTimeTimer: Timer?
    private var accumulatedElapsedTime: TimeInterval = 0
    private var elapsedTimeSegmentStartedAt: Date?
    
    init(
        reverseGeocodingRepository: ReverseGeocodingRepository = DefaultReverseGeocodingRepository(),
        activityRepository: ActivityRepository = DefaultActivityRepository()
    ) {
        self.reverseGeocodingRepository = reverseGeocodingRepository
        self.activityRepository = activityRepository
    }
    
    deinit {
        elapsedTimeTimer?.invalidate()
    }
    
    func startDistanceTracking() -> CLLocationDistance {
        lastRecordedLocation = nil
        totalDistance = 0
        maximumAltitudeInMeters = nil
        routePoints.removeAll()
        photoRecords.removeAll()
        maximumAltitudeDidChange?(nil)
        return totalDistance
    }
    
    func pauseDistanceTracking() {
        lastRecordedLocation = nil
    }
    
    func startElapsedTimeTracking() {
        elapsedTimeTimer?.invalidate()
        accumulatedElapsedTime = 0
        elapsedTimeSegmentStartedAt = Date()
        publishElapsedTime()
        startElapsedTimeTimer()
    }
    
    func pauseElapsedTimeTracking() {
        guard let elapsedTimeSegmentStartedAt else { return }
        
        accumulatedElapsedTime += Date().timeIntervalSince(elapsedTimeSegmentStartedAt)
        self.elapsedTimeSegmentStartedAt = nil
        elapsedTimeTimer?.invalidate()
        elapsedTimeTimer = nil
        publishElapsedTime()
    }
    
    func resumeElapsedTimeTracking() {
        guard elapsedTimeSegmentStartedAt == nil else { return }
        
        elapsedTimeSegmentStartedAt = Date()
        publishElapsedTime()
        startElapsedTimeTimer()
    }
    
    func recordDistance(at location: CLLocation) -> CLLocationDistance? {
        recordMaximumAltitude(at: location)
        
        guard location.horizontalAccuracy >= 0,
              location.horizontalAccuracy <= 30,
              abs(location.timestamp.timeIntervalSinceNow) <= 10 else {
            return nil
        }
        
        if let lastRecordedLocation {
            guard location.timestamp > lastRecordedLocation.timestamp else { return nil }
            totalDistance += location.distance(from: lastRecordedLocation)
        }
        
        let routePoint = WorkoutRoutePoint(
            pointIndex: routePoints.count + 1,
            coordinate: location.coordinate,
            altitude: location.altitude
        )
        routePoints.append(routePoint)
        lastRecordedLocation = location
        return totalDistance
    }
    
    @discardableResult
    func savePhotoRecord(_ photoRecord: WorkoutPhotoRecord, title: String) -> Int {
        var record = photoRecord
        record.locationTitle = title
        photoRecords.append(record)
        return photoRecords.count - 1
    }
    
    func routePoint(matching pointIndex: Int) -> WorkoutRoutePoint? {
        let arrayIndex = pointIndex - 1
        guard routePoints.indices.contains(arrayIndex),
              routePoints[arrayIndex].pointIndex == pointIndex else {
            return nil
        }
        return routePoints[arrayIndex]
    }
    
    private func recordMaximumAltitude(at location: CLLocation) {
        guard location.verticalAccuracy > 0,
              location.verticalAccuracy <= 30,
              abs(location.timestamp.timeIntervalSinceNow) <= 10,
              maximumAltitudeInMeters.map({ location.altitude > $0 }) ?? true else {
            return
        }
        
        maximumAltitudeInMeters = location.altitude
        maximumAltitudeDidChange?(location.altitude)
    }
    
    private func startElapsedTimeTimer() {
        elapsedTimeTimer?.invalidate()
        let timer = Timer(timeInterval: 1, repeats: true) { [weak self] _ in
            self?.publishElapsedTime()
        }
        elapsedTimeTimer = timer
        RunLoop.main.add(timer, forMode: .common)
    }
    
    private func publishElapsedTime() {
        elapsedTimeDidChange?(currentElapsedTime)
    }
    
    private var currentElapsedTime: TimeInterval {
        let activeSegmentElapsedTime = elapsedTimeSegmentStartedAt.map {
            Date().timeIntervalSince($0)
        } ?? 0
        return accumulatedElapsedTime + activeSegmentElapsedTime
    }
    
    // MARK: - Network
    
    func currentAddress(for location: CLLocation) async throws -> String? {
        if let lastReverseGeocodingLocation,
           location.distance(from: lastReverseGeocodingLocation) < 50 {
            return nil
        }
        
        let address = try await reverseGeocodingRepository.roadAddress(
            latitude: location.coordinate.latitude,
            longitude: location.coordinate.longitude
        )
        
        lastReverseGeocodingLocation = location
        return address
    }
    
    func startRecording(activityType: String, startedAt: String) async throws -> WorkoutRecordStartModel {
        let activity = try await activityRepository.createActivity(
            activityType: activityType,
            startedAt: startedAt
        )
        
        activityId = activity.activityId
        activityTitle = activity.title
        return activity
    }
    
    func changeActivityStatus(_ status: String) async throws {
        guard let activityId else {
            throw RouteeError.noData
        }
        
        _ = try await activityRepository.changeActivityStatus(
            activityId: activityId,
            requestDTO: ChangeActivityStatusRequestDTO(status: status)
        )
    }
    
    func finishRecording(title: String) async throws {
        guard let activityId,
              let backgroundMapImageURL,
              canFinishRecording else {
            throw RouteeError.noData
        }

        let normalizedCoverImageObjectKey = coverImageObjectKey.flatMap {
            $0.isEmpty ? nil : $0
        }
        
        let finishModel = WorkoutRecordFinishModel(
            title: title,
            distance: Int(totalDistance),
            durationSec: elapsedTimeInSeconds,
            maxAltitude: Int(maximumAltitudeInMeters ?? 0),
            mapImageUrl: backgroundMapImageURL,
            coverImageObjectKey: normalizedCoverImageObjectKey,
            tracks: routePoints.map {
                WorkoutRecordFinishModel.Track(
                    latitude: $0.coordinate.latitude,
                    longitude: $0.coordinate.longitude,
                    elevation: Int($0.altitude),
                    pointIndex: $0.pointIndex
                )
            },
            endedAt: Self.timeLineDateFormatter.string(from: Date())
        )
        
        try await activityRepository.finishActivity(activityId: activityId, requestModel: finishModel)
    }
    
    func uploadPhoto(at index: Int) async throws {
        guard let activityId,
              photoRecords.indices.contains(index) else {
            throw RouteeError.noData
        }
        
        let image = photoRecords[index].image
        let imageData = await Task.detached(priority: .userInitiated) {
            image.jpegData(compressionQuality: 0.8)
        }.value
        
        guard let imageData else {
            throw RouteeError.noData
        }
        
        let fileName = "\(UUID().uuidString).jpg"
        let presigned = try await activityRepository.timeLinePresignedURL(
            activityId: activityId,
            fileName: fileName
        )
        try await activityRepository.uploadTimeLineImage(
            presignedURL: presigned.presignedURL,
            imageData: imageData
        )
        
        photoRecords[index].objectKey = presigned.objectKey
        coverImageObjectKey = presigned.objectKey
        
        try await createTimeLine(
            for: photoRecords[index],
            objectKey: presigned.objectKey,
            title: photoRecords[index].locationTitle ?? ""
        )
    }
    
    func uploadBackgroundMap(image: UIImage) async throws {
        guard let activityId else {
            throw RouteeError.noData
        }
        
        let imageData = await Task.detached(priority: .userInitiated) {
            image.jpegData(compressionQuality: 0.8)
        }.value
        
        guard let imageData else {
            throw RouteeError.noData
        }
        
        let fileName = "\(UUID().uuidString).jpg"
        let presigned = try await activityRepository.backgroundMapPresignedURL(
            activityId: activityId,
            requestDTO: BackgroundMapPresignedURLRequestDTO(fileName: fileName)
        )
        try await activityRepository.uploadTimeLineImage(
            presignedURL: presigned.presignedURL,
            imageData: imageData
        )
        
        backgroundMapImageURL = try Self.imageURL(from: presigned.presignedURL)
    }
    
    private static func imageURL(from presignedURL: String) throws -> String {
        guard var components = URLComponents(string: presignedURL) else {
            throw RouteeError.URLError
        }
        
        components.query = nil
        components.fragment = nil
        
        guard let imageURL = components.string else {
            throw RouteeError.URLError
        }
        
        return imageURL
    }
    
    private func createTimeLine(for photoRecord: WorkoutPhotoRecord, objectKey: String, title: String) async throws {
        guard let activityId,
              let routePoint = routePoint(matching: photoRecord.pointIndex) else {
            throw RouteeError.noData
        }
        let timeLine = TimeLineRecordModel(
            title: title,
            imageObjectKey: objectKey,
            createdAt: Self.timeLineDateFormatter.string(from: photoRecord.createdAt),
            trackPointIndex: photoRecord.pointIndex,
            location: TimeLineRecordModel.Location(
                latitude: routePoint.coordinate.latitude,
                longitude: routePoint.coordinate.longitude,
                elevation: Int(routePoint.altitude),
                pointIndex: routePoint.pointIndex
            ),
            status: "SUCCESSFUL_CREATED"
        )
        
        try await activityRepository.createTimeLine(activityId: activityId, requestDTO: timeLine.toDTO())
    }
    
    private static let timeLineDateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.calendar = Calendar(identifier: .gregorian)
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.timeZone = .current
        formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss"
        return formatter
    }()
}
