//
//  TimeLineTrackMap.swift
//  Routee-iOS
//
//  Created by 초긍정행운의포춘쿠키 on 7/15/26.
//

import UIKit

import Kingfisher
import NMapsMap
import SnapKit
import Then

final class TimeLineTrackMap: BaseUIView {

    struct Photo {
        let image: UIImage
        let pointIndex: Int
    }

    // MARK: - Properties

    private var trackPoints: [TrackPoint]
    private var markers: [TimelineMarkerModel]
    private let photos: [Photo]
    private var shouldUpdateCamera = true
    private var shouldUpdatePhotoMarkers = true

    // MARK: - UI Properties

    private let naverMapView = NMFNaverMapView()
    private let pathOverlay = NMFPath()
    private var photoMarkers: [NMFMarker] = []

    // MARK: - Initializer

    init(
        trackPoints: [TrackPoint] = [],
        markers: [TimelineMarkerModel] = [],
        photos: [Photo] = []
    ) {
        self.trackPoints = trackPoints
        self.markers = markers
        self.photos = photos
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

    func updateRoute(
        trackPoints: [TrackPoint],
        markers: [TimelineMarkerModel]
    ) {
        self.trackPoints = trackPoints
        self.markers = markers
        shouldUpdateCamera = true
        shouldUpdatePhotoMarkers = true
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

        updatePhotoMarkers()
        updateCameraIfNeeded(locations)
    }

    private func updatePhotoMarkers() {
        guard shouldUpdatePhotoMarkers else { return }

        shouldUpdatePhotoMarkers = false
        removePhotoMarkers()

        markers.forEach { marker in
            guard let coordinate = coordinate(for: marker),
                  let url = URL(string: marker.thumbnailUrl) else { return }

            addPhotoMarker(marker, imageURL: url, at: coordinate)
        }

        photos.forEach { photo in
            guard let coordinate = coordinate(for: photo.pointIndex) else { return }

            addPhotoMarker(photo.image, pointIndex: photo.pointIndex, at: coordinate)
        }
    }

    private func coordinate(for marker: TimelineMarkerModel) -> NMGLatLng? {
        NMGLatLng(lat: marker.latitude, lng: marker.longitude)
    }

    private func coordinate(for pointIndex: Int) -> NMGLatLng? {
        let trackPointIndex = pointIndex - 1

        guard trackPoints.indices.contains(trackPointIndex) else { return nil }

        let trackPoint = trackPoints[trackPointIndex]
        return NMGLatLng(lat: trackPoint.latitude, lng: trackPoint.longitude)
    }

    private func addPhotoMarker(
        _ markerModel: TimelineMarkerModel,
        imageURL: URL,
        at coordinate: NMGLatLng
    ) {
        let pointIndex = markerModel.pointIndex
        let latitude = coordinate.lat
        let longitude = coordinate.lng

        guard pointIndex >= 0 else { return }

        KingfisherManager.shared.retrieveImage(with: imageURL) { result in
            guard case .success(let value) = result else { return }

            Task { @MainActor [weak self] in
                self?.addPhotoMarker(
                    value.image,
                    pointIndex: pointIndex,
                    at: NMGLatLng(lat: latitude, lng: longitude)
                )
            }
        }
    }

    private func addPhotoMarker(
        _ sourceImage: UIImage,
        pointIndex: Int,
        at coordinate: NMGLatLng
    ) {
        let markerSize = CGSize(width: 42, height: 42)

        guard pointIndex >= 0 else { return }

        Task { [weak self] in
            let thumbnailImage = await Task.detached(priority: .userInitiated) {
                sourceImage
                    .resized(to: markerSize)
                    .thumbnailImage(borderWidth: 3, borderColor: .mint300, cornerRadius: 12)
            }.value

            await MainActor.run { [weak self] in
                guard let self else { return }

                let marker = NMFMarker()
                marker.tag = UInt(pointIndex)
                marker.position = coordinate
                marker.iconImage = NMFOverlayImage(image: thumbnailImage)
                marker.width = markerSize.width
                marker.height = markerSize.height
                marker.anchor = CGPoint(x: 0.5, y: 0.5)
                marker.mapView = naverMapView.mapView
                photoMarkers.append(marker)
            }
        }
    }

    private func removePhotoMarkers() {
        photoMarkers.forEach { $0.mapView = nil }
        photoMarkers.removeAll()
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
