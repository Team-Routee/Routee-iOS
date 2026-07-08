//
//  WorkoutView.swift
//  Routee-iOS
//
//  Created by LEESANGYUP on 7/8/26.
//

import UIKit

import NMapsMap
import SnapKit
import Then

final class WorkoutView: BaseUIView {
    
    // MARK: - UI Properties
    
    private let routeeMapView = NMFNaverMapView()
    
    var mapView: NMFMapView {
        routeeMapView.mapView
    }

    override func setUI() {
        addSubviews(routeeMapView)
    }
    
    override func setStyle() {
        routeeMapView.do {
            $0.showLocationButton = true
            $0.mapView.isNightModeEnabled = true
        }
    }
    
    override func setLayout() {
        routeeMapView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
    }
}
