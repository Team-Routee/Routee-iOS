//
//  TimeLineTrackMap.swift
//  Routee-iOS
//
//  Created by 초긍정행운의포춘쿠키 on 7/15/26.
//

import UIKit

import NMapsMap
import SnapKit
import Then

final class TimeLineTrackMap: BaseUIView {

    // MARK: - Properties

    private var trackPoints: [TrackPoint]
    private var shouldUpdateCamera = true

    // MARK: - UI Properties

    private let naverMapView = NMFNaverMapView()
    private let pathOverlay = NMFPath()

    // MARK: - Initializer

    init(trackPoints: [TrackPoint] = []) {
        self.trackPoints = trackPoints
        super.init(frame: .zero)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Life Cycle

    override func layoutSubviews() {
        super.layoutSubviews()

        updateRoutePath()
    }

    // MARK: - Public Methods

    func updateTrackPoints(_ trackPoints: [TrackPoint]) {
        self.trackPoints = trackPoints
        shouldUpdateCamera = true
        setNeedsLayout()
    }

    // MARK: - UI Setting

    override func setStyle() {
        naverMapView.do {
            $0.showLocationButton = false
            $0.showScaleBar = false
            $0.showZoomControls = false
            $0.showCompass = false
            $0.mapView.isNightModeEnabled = true
            $0.mapView.setLayerGroup(NMF_LAYER_GROUP_MOUNTAIN, isEnabled: true)
            $0.mapView.logoAlign = .leftBottom
            $0.clipsToBounds = true
            $0.layer.cornerRadius = 12
        }

        pathOverlay.do {
            $0.color = .mint_300
            $0.outlineWidth = 0
            $0.width = 4
        }
    }

    override func setUI() {
        addSubview(naverMapView)
    }

    override func setLayout() {
        naverMapView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
    }

    // MARK: - Private Methods

    private func updateRoutePath() {
        guard bounds.width > 0,
              bounds.height > 0 else { return }

        let locations = trackPoints.map {
            NMGLatLng(lat: $0.latitude, lng: $0.longitude)
        }

        guard locations.count >= 2 else {
            pathOverlay.mapView = nil
            return
        }

        pathOverlay.path = NMGLineString(points: locations)
        pathOverlay.mapView = naverMapView.mapView

        updateCameraIfNeeded(locations)
    }

    private func updateCameraIfNeeded(_ locations: [NMGLatLng]) {
        guard shouldUpdateCamera else { return }

        shouldUpdateCamera = false

        let latitudes = locations.map(\.lat)
        let longitudes = locations.map(\.lng)

        guard let minLatitude = latitudes.min(),
              let maxLatitude = latitudes.max(),
              let minLongitude = longitudes.min(),
              let maxLongitude = longitudes.max() else { return }

        let bounds = NMGLatLngBounds(
            southWest: NMGLatLng(lat: minLatitude, lng: minLongitude),
            northEast: NMGLatLng(lat: maxLatitude, lng: maxLongitude)
        )

        let cameraUpdate = NMFCameraUpdate(fit: bounds, padding: 40)
        cameraUpdate.animation = .easeIn
        naverMapView.mapView.moveCamera(cameraUpdate)
    }
}
