//
//  WorkoutRoutePoint.swift
//  Routee-iOS
//
//  Created by LEESANGYUP on 7/15/26.
//

import CoreLocation

import NMapsMap

struct WorkoutRoutePoint {
    let pointIndex: Int
    let coordinate: CLLocationCoordinate2D
    let altitude: CLLocationDistance

    var latLng: NMGLatLng {
        NMGLatLng(lat: coordinate.latitude, lng: coordinate.longitude)
    }
}
