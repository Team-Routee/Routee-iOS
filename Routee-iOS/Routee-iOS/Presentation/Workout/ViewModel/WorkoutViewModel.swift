//
//  WorkoutViewModel.swift
//  Routee-iOS
//
//  Created by LEESANGYUP on 7/9/26.
//

import CoreLocation
import Foundation

final class WorkoutViewModel {
    private let reverseGeocodingRepository: ReverseGeocodingRepository
    private var lastReverseGeocodingLocation: CLLocation?
    private var lastRecordedLocation: CLLocation?
    private var totalDistance: CLLocationDistance = 0
    
    init(reverseGeocodingRepository: ReverseGeocodingRepository = DefaultReverseGeocodingRepository()) {
        self.reverseGeocodingRepository = reverseGeocodingRepository
    }

    func startDistanceTracking() -> CLLocationDistance {
        lastRecordedLocation = nil
        totalDistance = 0
        return totalDistance
    }

    func pauseDistanceTracking() {
        lastRecordedLocation = nil
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
