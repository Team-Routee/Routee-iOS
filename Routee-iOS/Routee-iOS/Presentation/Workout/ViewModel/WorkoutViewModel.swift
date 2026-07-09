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
    
    init(reverseGeocodingRepository: ReverseGeocodingRepository = DefaultReverseGeocodingRepository()) {
        self.reverseGeocodingRepository = reverseGeocodingRepository
    }
    
    func currentAddress(for location: CLLocation) async throws -> String? {
        if let lastReverseGeocodingLocation,
           location.distance(from: lastReverseGeocodingLocation) < 50 {
            return nil
        }
        
        return try await reverseGeocodingRepository.roadAddress(
            latitude: location.coordinate.latitude,
            longitude: location.coordinate.longitude
        )
        
        lastReverseGeocodingLocation = location
    }
}
