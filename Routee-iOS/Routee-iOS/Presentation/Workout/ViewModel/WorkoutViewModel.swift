//
//  WorkoutViewModel.swift
//  Routee-iOS
//
//  Created by LEESANGYUP on 7/9/26.
//

import CoreLocation
import Foundation

final class WorkoutViewModel {
    var elapsedTimeDidChange: ((TimeInterval) -> Void)?
    var elapsedTimeInSeconds: Int {
        max(0, Int(currentElapsedTime))
    }

    private let reverseGeocodingRepository: ReverseGeocodingRepository
    private var lastReverseGeocodingLocation: CLLocation?
    private var lastRecordedLocation: CLLocation?
    private var totalDistance: CLLocationDistance = 0
    private var elapsedTimeTimer: Timer?
    private var accumulatedElapsedTime: TimeInterval = 0
    private var elapsedTimeSegmentStartedAt: Date?
    
    init(reverseGeocodingRepository: ReverseGeocodingRepository = DefaultReverseGeocodingRepository()) {
        self.reverseGeocodingRepository = reverseGeocodingRepository
    }

    deinit {
        elapsedTimeTimer?.invalidate()
    }

    func startDistanceTracking() -> CLLocationDistance {
        lastRecordedLocation = nil
        totalDistance = 0
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
        guard location.horizontalAccuracy >= 0,
              location.horizontalAccuracy <= 30,
              abs(location.timestamp.timeIntervalSinceNow) <= 10 else {
            return nil
        }

        if let lastRecordedLocation {
            guard location.timestamp > lastRecordedLocation.timestamp else { return nil }
            totalDistance += location.distance(from: lastRecordedLocation)
        }

        lastRecordedLocation = location
        return totalDistance
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
}
