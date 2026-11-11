//
//  WorkoutViewModel.swift
//  Routee-iOS
//
//  Created by LEESANGYUP on 7/9/26.
//

import CoreLocation
import UIKit

enum WorkoutRecoverySaveError: Error {
    case rejected
}

@MainActor
final class WorkoutViewModel {
    var elapsedTimeDidChange: ((TimeInterval) -> Void)?
    var maximumAltitudeDidChange: ((CLLocationDistance?) -> Void)?
    var elapsedTimeInSeconds: Int {
        max(0, Int(currentElapsedTime))
    }
    private(set) var maximumAltitudeInMeters: CLLocationDistance?
    private(set) var routePoints: [WorkoutRoutePoint] = []
    private(set) var photoRecords: [WorkoutPhotoRecord] = []
    var recoveryLastRecordedAt: Date? {
        recoveryEndedAt ?? recoveryCheckpointAt
    }

    private(set) var activityId: Int64?
    private(set) var courseList: CourseListModel?
    private(set) var activityTitle: String?
    private(set) var mapImageObjectKey: String?
    private(set) var coverImageObjectKey: String?
    
    private let reverseGeocodingRepository: ReverseGeocodingRepository
    private let activityRepository: ActivityRepository
    private var lastReverseGeocodingLocation: CLLocation?
    private var lastRecordedLocation: CLLocation?
    private(set) var totalDistance: CLLocationDistance = 0
    private var elapsedTimeTimer: Timer?
    private var accumulatedElapsedTime: TimeInterval = 0
    private var elapsedTimeSegmentStartedAt: Date?
    private let recoveryStore: WorkoutRecoveryStore?
    private var recoveryCheckpointAt: Date?
    private var recoveryEndedAt: Date?
    private var activityStartedAt: Date?
    
    init(
        reverseGeocodingRepository: ReverseGeocodingRepository = DefaultReverseGeocodingRepository(),
        activityRepository: ActivityRepository = DefaultActivityRepository()
    ) {
        self.reverseGeocodingRepository = reverseGeocodingRepository
        self.activityRepository = activityRepository
        recoveryStore = WorkoutRecoveryStore(accountId: DefaultKeychainService().read(.appleUserID))
    }
    
    isolated deinit {
        elapsedTimeTimer?.invalidate()
    }
    
    func startDistanceTracking() -> CLLocationDistance {
        lastRecordedLocation = nil
        totalDistance = 0
        maximumAltitudeInMeters = nil
        routePoints.removeAll()
        photoRecords.removeAll()
        maximumAltitudeDidChange?(nil)
        checkpointWorkout()
        return totalDistance
    }
    
    func pauseDistanceTracking() {
        lastRecordedLocation = nil
    }
    
    func startElapsedTimeTracking() {
        elapsedTimeTimer?.invalidate()
        accumulatedElapsedTime = 0
        let startedAt = Date()
        elapsedTimeSegmentStartedAt = startedAt
        recoveryCheckpointAt = startedAt
        recoveryEndedAt = nil
        publishElapsedTime()
        startElapsedTimeTimer()
    }
    
    func pauseElapsedTimeTracking() {
        guard let elapsedTimeSegmentStartedAt else { return }
        
        let pausedAt = Date()
        accumulatedElapsedTime += max(0, pausedAt.timeIntervalSince(elapsedTimeSegmentStartedAt))
        if recoveryCheckpointAt != nil {
            recoveryCheckpointAt = pausedAt
        }
        self.elapsedTimeSegmentStartedAt = nil
        elapsedTimeTimer?.invalidate()
        elapsedTimeTimer = nil
        publishElapsedTime()
        checkpointWorkout()
    }
    
    func resumeElapsedTimeTracking() {
        guard elapsedTimeSegmentStartedAt == nil else { return }
        
        if recoveryEndedAt != nil {
            mapImageObjectKey = nil
        }
        recoveryEndedAt = nil
        elapsedTimeSegmentStartedAt = Date()
        publishElapsedTime()
        startElapsedTimeTimer()
        checkpointWorkout()
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
        checkpointIfDue()
        return totalDistance
    }
    
    @discardableResult
    func savePhotoRecord(_ photoRecord: WorkoutPhotoRecord, title: String) -> Int {
        var record = photoRecord
        record.locationTitle = title
        photoRecords.append(record)
        if let recoveryStore, recoveryCheckpointAt != nil {
            do {
                guard let data = record.image.jpegData(compressionQuality: 0.8) else {
                    throw RouteeError.noData
                }
                try recoveryStore.savePhoto(data, id: record.recoveryId)
            } catch {
                RouteeLogger.error(error)
            }
        }
        checkpointWorkout()
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

    func routePointForPhoto(fallbackLocation: CLLocation?) -> WorkoutRoutePoint? {
        if let lastRoutePoint = routePoints.last {
            return lastRoutePoint
        }

        guard let fallbackLocation,
              CLLocationCoordinate2DIsValid(fallbackLocation.coordinate) else {
            return nil
        }

        recordMaximumAltitude(at: fallbackLocation)

        let routePoint = WorkoutRoutePoint(
            pointIndex: 1,
            coordinate: fallbackLocation.coordinate,
            altitude: fallbackLocation.altitude
        )
        routePoints.append(routePoint)
        lastRecordedLocation = fallbackLocation
        checkpointWorkout()
        return routePoint
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
            Task { @MainActor [weak self] in
                self?.publishElapsedTime()
                self?.checkpointIfDue()
            }
        }
        elapsedTimeTimer = timer
        RunLoop.main.add(timer, forMode: .common)
    }
    
    private func publishElapsedTime() {
        elapsedTimeDidChange?(currentElapsedTime)
    }
    
    private var currentElapsedTime: TimeInterval {
        elapsedTime(at: Date())
    }

    private func elapsedTime(at date: Date) -> TimeInterval {
        let activeSegmentElapsedTime = elapsedTimeSegmentStartedAt.map {
            max(0, date.timeIntervalSince($0))
        } ?? 0
        return accumulatedElapsedTime + activeSegmentElapsedTime
    }

    // MARK: - Workout Recovery

    func restoreWorkoutIfAvailable() -> Bool {
        guard let recoveryStore else { return false }

        do {
            guard let snapshot = try recoveryStore.load() else { return false }

            elapsedTimeTimer?.invalidate()
            elapsedTimeTimer = nil
            elapsedTimeSegmentStartedAt = nil
            accumulatedElapsedTime = snapshot.elapsedTime
            lastRecordedLocation = nil
            activityId = snapshot.activityId
            activityTitle = snapshot.activityTitle
            totalDistance = snapshot.distance
            maximumAltitudeInMeters = snapshot.maximumAltitude
            routePoints = snapshot.routePoints.map {
                WorkoutRoutePoint(
                    pointIndex: $0.pointIndex,
                    coordinate: CLLocationCoordinate2D(latitude: $0.latitude, longitude: $0.longitude),
                    altitude: $0.altitude
                )
            }
            photoRecords = snapshot.photos.compactMap { photo in
                do {
                    let data = try recoveryStore.loadPhoto(id: photo.id)
                    guard let image = UIImage(data: data) else { throw RouteeError.noData }
                    return WorkoutPhotoRecord(
                        image: image,
                        pointIndex: photo.pointIndex,
                        createdAt: photo.createdAt,
                        recoveryId: photo.id,
                        locationTitle: photo.locationTitle,
                        objectKey: photo.objectKey,
                        timelineId: photo.timelineId
                    )
                } catch {
                    RouteeLogger.error(error)
                    return nil
                }
            }
            courseList = snapshot.courseRoutes.map { routes in
                CourseListModel(
                    activityId: snapshot.activityId,
                    routes: routes.map {
                        CourseListModel.RouteData(routeId: $0.routeId, name: $0.name, sequence: $0.sequence)
                    }
                )
            }
            mapImageObjectKey = snapshot.mapImageObjectKey
            coverImageObjectKey = snapshot.coverImageObjectKey
            recoveryCheckpointAt = snapshot.lastRecordedAt
            recoveryEndedAt = snapshot.endedAt
            activityStartedAt = snapshot.startedAt

            publishElapsedTime()
            maximumAltitudeDidChange?(maximumAltitudeInMeters)
            return true
        } catch {
            RouteeLogger.error(error)
            return false
        }
    }

    func isRecoveredWorkoutCompleted() async throws -> Bool {
        guard let activityId, let recoveryEndedAt else { return false }

        let calendar = Calendar(identifier: .gregorian)
        let startMonth = calendar.dateComponents([.year, .month], from: activityStartedAt ?? recoveryEndedAt)
        let endMonth = calendar.dateComponents([.year, .month], from: recoveryEndedAt)
        let months = startMonth == endMonth ? [startMonth] : [startMonth, endMonth]
        for month in months {
            guard let year = month.year, let month = month.month else { continue }
            try Task.checkCancellation()
            let completed = try await activityRepository.getWorkoutList(year: year, month: month)
            if completed.contains(where: { $0.activityId == activityId }) {
                return true
            }
        }
        return false
    }

    func checkpointWorkout(endedAt: Date? = nil) {
        guard let activityId, let lastRecordedAt = recoveryCheckpointAt else { return }

        if let endedAt {
            recoveryEndedAt = endedAt
        }
        let now = Date()
        let checkpointAt = elapsedTimeSegmentStartedAt != nil && recoveryEndedAt == nil ? now : lastRecordedAt
        recoveryCheckpointAt = checkpointAt
        guard let recoveryStore else { return }

        let snapshot = WorkoutRecoverySnapshot(
            activityId: activityId,
            activityTitle: activityTitle,
            startedAt: activityStartedAt,
            lastRecordedAt: checkpointAt,
            endedAt: recoveryEndedAt,
            elapsedTime: elapsedTime(at: checkpointAt),
            distance: totalDistance,
            maximumAltitude: maximumAltitudeInMeters,
            routePoints: routePoints.map {
                WorkoutRecoverySnapshot.TrackPoint(
                    pointIndex: $0.pointIndex,
                    latitude: $0.coordinate.latitude,
                    longitude: $0.coordinate.longitude,
                    altitude: $0.altitude
                )
            },
            photos: photoRecords.map {
                WorkoutRecoverySnapshot.Photo(
                    id: $0.recoveryId,
                    pointIndex: $0.pointIndex,
                    createdAt: $0.createdAt,
                    locationTitle: $0.locationTitle,
                    objectKey: $0.objectKey,
                    timelineId: $0.timelineId
                )
            },
            courseRoutes: courseList?.routes.map {
                WorkoutRecoverySnapshot.CourseRoute(routeId: $0.routeId, name: $0.name, sequence: $0.sequence)
            },
            mapImageObjectKey: mapImageObjectKey,
            coverImageObjectKey: coverImageObjectKey
        )

        do {
            try recoveryStore.save(snapshot)
        } catch {
            RouteeLogger.error(error)
        }
    }

    func clearWorkoutRecovery() {
        recoveryCheckpointAt = nil
        recoveryEndedAt = nil

        do {
            try recoveryStore?.clear()
        } catch {
            RouteeLogger.error(error)
        }
    }

    private func checkpointIfDue() {
        guard elapsedTimeSegmentStartedAt != nil,
              let recoveryCheckpointAt,
              Date().timeIntervalSince(recoveryCheckpointAt) >= 5 else { return }

        checkpointWorkout()
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
        
        clearWorkoutRecovery()
        activityId = activity.activityId
        activityStartedAt = Self.timeLineDateFormatter.date(from: startedAt)
        activityTitle = activity.title
        courseList = nil
        mapImageObjectKey = nil
        coverImageObjectKey = nil
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
    
    func finishRecording(
        title: String,
        routePointsSnapshot: [WorkoutRoutePoint],
        endedAt: Date,
        isRecovering: Bool = false
    ) async throws {
        guard let activityId,
              let mapImageObjectKey else {
            throw RouteeError.noData
        }

        try await retryFailedPhotoUploads()
        try await saveCourseListIfNeeded(activityId: activityId)
        
        let finishModel = WorkoutRecordFinishModel(
            title: title,
            distance: Int(totalDistance),
            durationSec: elapsedTimeInSeconds,
            maxAltitude: Int(maximumAltitudeInMeters ?? 0),
            mapImageObjectKey: mapImageObjectKey,
            tracks: routePointsSnapshot.map {
                WorkoutRecordFinishModel.Track(
                    latitude: $0.coordinate.latitude,
                    longitude: $0.coordinate.longitude,
                    elevation: Int($0.altitude),
                    pointIndex: $0.pointIndex
                )
            },
            endedAt: Self.timeLineDateFormatter.string(from: endedAt)
        )
        
        do {
            try await activityRepository.finishActivity(activityId: activityId, requestModel: finishModel)
        } catch let error as RouteeError where isRecovering && (error == .clientError || error == .notFound) {
            throw WorkoutRecoverySaveError.rejected
        }
    }
    
    private func saveCourseListIfNeeded(activityId: Int64) async throws {
        let titles = photoRecords.compactMap(\.locationTitle)
            .map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
            .filter { !$0.isEmpty }
        let savedRoutes = courseList?.routes.sorted { $0.sequence < $1.sequence } ?? []
        guard titles != savedRoutes.map(\.name) else { return }

        let routes = titles.enumerated().map { index, title in
            let routeId = savedRoutes.indices.contains(index) ? savedRoutes[index].routeId : 0
            return RouteData(routeId: routeId, name: title, sequence: index + 1)
        }
        if savedRoutes.isEmpty {
            do {
                courseList = try await activityRepository.createCourseList(
                    activityId: activityId,
                    requestDTO: CreateCourseListRequestDTO(routes: routes)
                )
            } catch RouteeError.networkError(statusCode: 409, message: _) {
                courseList = try await activityRepository.updateCourseList(
                    activityId: activityId,
                    requestDTO: UpdateCourseListRequestDTO(routes: routes)
                )
            }
        } else {
            courseList = try await activityRepository.updateCourseList(
                activityId: activityId,
                requestDTO: UpdateCourseListRequestDTO(routes: routes)
            )
        }
        checkpointWorkout()
    }

    func uploadPhoto(at index: Int) async throws {
        guard let activityId,
              photoRecords.indices.contains(index) else {
            throw RouteeError.noData
        }

        guard photoRecords[index].timelineId == nil else { return }

        let objectKey: String
        if let uploadedObjectKey = photoRecords[index].objectKey {
            objectKey = uploadedObjectKey
        } else {
            let record = photoRecords[index]
            let imageData: Data?
            if let storedData = try? recoveryStore?.loadPhoto(id: record.recoveryId) {
                imageData = storedData
            } else {
                imageData = await Task.detached(priority: .userInitiated) {
                    record.image.jpegData(compressionQuality: 0.8)
                }.value
            }

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
            objectKey = presigned.objectKey
            checkpointWorkout()
        }

        let timelineId = try await createTimeLine(
            for: photoRecords[index],
            objectKey: objectKey,
            title: photoRecords[index].locationTitle ?? ""
        )
        photoRecords[index].timelineId = timelineId
        checkpointWorkout()
    }

    private func retryFailedPhotoUploads() async throws {
        var firstError: Error?

        for index in photoRecords.indices where photoRecords[index].timelineId == nil {
            do {
                try await uploadPhoto(at: index)
            } catch {
                firstError = firstError ?? error
            }
        }

        if let firstError {
            throw firstError
        }
    }

    func deleteTimeline(at index: Int) async throws {
        guard let activityId,
              photoRecords.indices.contains(index) else {
            throw RouteeError.noData
        }

        if let timelineId = photoRecords[index].timelineId {
            try await activityRepository.deleteTimeline(
                activityId: activityId,
                timelineId: timelineId
            )
        }

        let deletedPhoto = photoRecords.remove(at: index)
        if coverImageObjectKey == deletedPhoto.objectKey {
            coverImageObjectKey = photoRecords.reversed().compactMap(\.objectKey).first
        }
        checkpointWorkout()
    }

    func updateTimelineTitle(at index: Int, title: String) async throws {
        guard let activityId,
              photoRecords.indices.contains(index) else {
            throw RouteeError.noData
        }

        photoRecords[index].locationTitle = title
        checkpointWorkout()

        guard let timelineId = photoRecords[index].timelineId else { return }

        let response = try await activityRepository.updateTimelineTitle(
            activityId: activityId,
            timelineId: timelineId,
            requestDTO: UpdateTimelineTitleRequestDTO(title: title)
        )
        photoRecords[index].locationTitle = response.title
        checkpointWorkout()
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
        
        mapImageObjectKey = presigned.objectKey
        checkpointWorkout()
    }
    
    private func createTimeLine(
        for photoRecord: WorkoutPhotoRecord,
        objectKey: String,
        title: String
    ) async throws -> Int64 {
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
        
        return try await activityRepository.createTimeLine(
            activityId: activityId,
            requestDTO: timeLine.toDTO()
        )
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
