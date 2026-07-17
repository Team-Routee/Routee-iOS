//
//  WorkoutView.swift
//  Routee-iOS
//
//  Created by LEESANGYUP on 7/8/26.
//

import CoreLocation
import UIKit

import Lottie
import NMapsMap
import SnapKit
import Then

final class WorkoutView: BaseUIView {
    
    // MARK: - Properties
    
    var distance = "0.00"
    var time = "00:00"
    var altitude = "0"
    
    // MARK: - UI Properties
    
    private let routeeMapView = NMFNaverMapView()
    private let gradiantHeaderLayer = CAGradientLayer()
    private let routeeLogo = UIImageView()
    private let currentLocationStackView = UIStackView()
    private let currentLocationImage = UIImageView()
    private let currentLocationLabel = UILabel()
    private lazy var workoutMetric = WorkoutMetric(distance: distance, time: time, altitude: altitude)
    private let userLocationIcon = NMFOverlayImage(
        image: UIImage.icNow.resized(to: CGSize(width: 42, height: 42))
    )
    private let pathOverlay = NMFPath()
    var photoMarkers: [NMFMarker] = []
    lazy var moveToUserlocationButton = UIButton(type: .custom)
    lazy var recordButton = RouteeButton(titleText: "등산 기록", type: .enabled)
    lazy var pauseButton = UIButton()
    lazy var cameraOnButton = UIButton()
    private let activityButtonStackView = UIStackView()
    private let workoutPauseView = WorkoutPauseView()
    var restartButton: UIButton { workoutPauseView.restartButton }
    var finishButton: UIButton { workoutPauseView.finishButton }
    
    var mapView: NMFMapView { routeeMapView.mapView }
    private let countdownAnimationView = LottieAnimationView(asset: "countdown")
    private lazy var finishAnimationView = LottieAnimationView(dotLottieAsset: "routeefinish")
    
    // MARK: - UI Setting
    
    override func setUI() {
        addSubviews(routeeMapView, countdownAnimationView, finishAnimationView, workoutPauseView)
        
        routeeMapView.addSubviews(
            routeeLogo,
            currentLocationStackView,
            workoutMetric,
            moveToUserlocationButton,
            recordButton,
            activityButtonStackView
        )
        
        routeeMapView.layer.addSublayer(gradiantHeaderLayer)
        
        currentLocationStackView.addArrangedSubviews(currentLocationImage, currentLocationLabel)
        
        activityButtonStackView.addArrangedSubviews(pauseButton, cameraOnButton)
    }
    
    override func setStyle() {
        applyLocationOverlayStyle()
        
        mapSetting()
        
        countdownAnimationView.do {
            $0.backgroundColor = .static_black
            $0.contentMode = .scaleAspectFill
            $0.clipsToBounds = true
            $0.loopMode = .playOnce
            $0.isHidden = true
        }
        
        finishAnimationView.do {
            $0.contentMode = .scaleAspectFill
            $0.clipsToBounds = true
            $0.loopMode = .playOnce
            $0.isHidden = true
        }
        
        routeeLogo.do {
            $0.image = .routeeLogoMintMd
            $0.contentMode = .scaleAspectFit
            $0.layer.zPosition = 2
        }
        
        gradiantHeaderLayer.do {
            $0.colors = [
                UIColor.grey_900.cgColor,
                UIColor.grey_900.withAlphaComponent(0).cgColor
            ]
            $0.locations = [0, 1]
            $0.startPoint = CGPoint(x: 0, y: 0.15)
            $0.endPoint = CGPoint(x: 0, y: 1)
            $0.zPosition = 1
        }
        
        currentLocationImage.do {
            $0.image = .icLocationInfoSmGradient
            $0.contentMode = .scaleAspectFit
        }
        
        currentLocationLabel.do {
            $0.text = "위치 권한 허용이 필요합니다."
            $0.font = .label_m_12
            $0.textColor = .grey_50
        }
        
        currentLocationStackView.do {
            $0.axis = .horizontal
            $0.alignment = .center
            $0.spacing = 2
            $0.backgroundColor = .grey500
            $0.layer.cornerRadius = 16
            $0.clipsToBounds = true
            $0.layoutMargins = UIEdgeInsets(top: 0, left: 8, bottom: 0, right: 12)
            $0.isLayoutMarginsRelativeArrangement = true
            $0.layer.zPosition = 2
        }
        
        moveToUserlocationButton.do {
            $0.setImage(.icInplace, for: .normal)
            $0.backgroundColor = .static_black
            $0.layer.cornerRadius = 22
            $0.clipsToBounds = true
            $0.isHidden = false
            $0.layer.zPosition = 2
        }
        
        pathOverlay.do {
            $0.color = .mint_300
            $0.outlineWidth = 0
            $0.width = 4
        }
        
        pauseButton.do {
            $0.setImageTitle(
                title: "정지",
                image: .icStop,
                font: .label_sb_16,
                foregroundColor: .bgPrimary,
                imagePadding: 4
            )
            $0.backgroundColor = .staticWhite
            $0.layer.cornerRadius = 30
            $0.clipsToBounds = true
        }
        
        cameraOnButton.do {
            $0.setImage(.icCameraFillBlack, for: .normal)
            $0.backgroundColor = .mint300
            $0.layer.cornerRadius = 30
            $0.clipsToBounds = true
        }
        
        activityButtonStackView.do {
            $0.spacing = 12
            $0.axis = .horizontal
            $0.alignment = .center
        }
        
        workoutPauseView.isHidden = true
    }
    
    override func setLayout() {
        routeeMapView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
        
        countdownAnimationView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
        
        finishAnimationView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
        
        workoutPauseView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
        
        routeeLogo.snp.makeConstraints {
            $0.top.equalTo(safeAreaLayoutGuide).inset(14)
            $0.centerX.equalToSuperview()
        }
        
        currentLocationStackView.snp.makeConstraints {
            $0.top.equalTo(routeeLogo.snp.bottom).offset(22)
            $0.centerX.equalTo(routeeLogo)
            $0.height.equalTo(32)
        }
        
        workoutMetric.snp.makeConstraints {
            $0.top.equalTo(safeAreaLayoutGuide).offset(20)
            $0.horizontalEdges.equalToSuperview().inset(16)
        }
        
        currentLocationImage.snp.makeConstraints {
            $0.size.equalTo(24)
        }
        
        moveToUserlocationButton.snp.makeConstraints {
            $0.trailing.equalTo(recordButton)
            $0.bottom.equalTo(recordButton.snp.top).offset(-12)
            $0.size.equalTo(44)
        }
        
        recordButton.snp.makeConstraints {
            $0.centerX.equalToSuperview()
            $0.bottom.equalTo(routeeMapView.safeAreaLayoutGuide).inset(78)
        }
        
        pauseButton.snp.makeConstraints {
            $0.width.equalTo(108)
            $0.height.equalTo(60)
        }
        
        cameraOnButton.snp.makeConstraints {
            $0.size.equalTo(60)
        }
        
        activityButtonStackView.snp.makeConstraints {
            $0.bottom.equalTo(safeAreaLayoutGuide).inset(31)
            $0.centerX.equalToSuperview()
        }
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        gradiantHeaderLayer.frame = CGRect(
            x: 0,
            y: 0,
            width: bounds.width,
            height: 141
        )
    }
    
    private func mapSetting() {
        routeeMapView.do {
            $0.showLocationButton = false
            $0.showScaleBar = false
            $0.showZoomControls = false
            $0.showCompass = false
            $0.mapView.isNightModeEnabled = true
            $0.mapView.addCameraDelegate(delegate: self)
            $0.mapView.setLayerGroup(NMF_LAYER_GROUP_MOUNTAIN, isEnabled: true)
            
            $0.mapView.logoAlign = .leftBottom
        }
    }
    
    // MARK: - Public Methods
    
    func updateRoutePath(_ locations: [NMGLatLng]) {
        guard locations.count >= 2 else {
            pathOverlay.mapView = nil
            return
        }
        
        pathOverlay.path = NMGLineString(points: locations)
        pathOverlay.mapView = mapView
    }

    func updateDistance(_ distanceInMeters: CLLocationDistance) {
        let distanceInKilometers = distanceInMeters / 1_000
        let formattedDistance = String(format: "%.2f", distanceInKilometers)
        workoutMetric.updateDistance(formattedDistance)
        workoutPauseView.updateDistance(formattedDistance)
    }

    func updateElapsedTime(_ elapsedTime: TimeInterval) {
        let totalSeconds = max(0, Int(elapsedTime))
        let hours = totalSeconds / 3_600
        let minutes = (totalSeconds % 3_600) / 60
        workoutMetric.updateTime(String(format: "%02d:%02d", hours, minutes))
        workoutPauseView.updateTime(String(format: "%02dh %02dm", hours, minutes))
    }

    func updateMaximumAltitude(_ altitudeInMeters: CLLocationDistance?) {
        let formattedAltitude = altitudeInMeters.map { String(Int($0.rounded())) } ?? "0"
        workoutMetric.updateMaximumAltitude(formattedAltitude)
        workoutPauseView.updateAltitude(formattedAltitude)
    }
    
    func updateCurrentLocationAddress(_ address: String) {
        currentLocationLabel.text = address
    }
    
    func showLocationOverlay() {
        mapView.locationOverlay.hidden = false
        mapView.positionMode = .direction
        applyLocationOverlayStyle()
    }
    
    func hideLocationOverlay() {
        mapView.locationOverlay.hidden = true
        mapView.positionMode = .disabled
    }
    
    func updateUserLocation(_ latLng: NMGLatLng, course: CLLocationDirection) {
        mapView.locationOverlay.location = latLng
        applyLocationOverlayStyle()
        
        guard course >= 0 else { return }
        
        mapView.locationOverlay.heading = course
    }
    
    func focusOnUserDirection() {
        mapView.positionMode = .direction
        applyLocationOverlayStyle()
    }
    
    func moveCamera(to latLng: NMGLatLng, zoomTo zoom: Double? = nil) {
        let cameraUpdate = zoom.map { NMFCameraUpdate(scrollTo: latLng, zoomTo: $0) }
        ?? NMFCameraUpdate(scrollTo: latLng)
        cameraUpdate.animation = .easeIn
        mapView.moveCamera(cameraUpdate)
    }

    func captureBackgroundMapImage(fitting coordinates: [NMGLatLng]) async -> UIImage? {
        guard !coordinates.isEmpty else { return nil }

        hideLocationOverlay()
        pathOverlay.mapView = nil
        removePhotoMarkers()

        let bounds = NMGLatLngBounds(latLngs: coordinates)
        await mapView.moveCamera(NMFCameraUpdate(fit: bounds, padding: 48))

        try? await Task.sleep(for: .milliseconds(800))

        return await withCheckedContinuation { continuation in
            routeeMapView.takeSnapShot { image in
                continuation.resume(returning: image)
            }
        }
    }
    
    // MARK: - Private Methods
    
    private func applyLocationOverlayStyle() {
        mapView.locationOverlay.icon = userLocationIcon
    }
    
}

extension WorkoutView {
    func configure(for mode: WorkoutMode) {
        let isReady = mode == .ready
        let isRecording = mode == .recording
        let isPaused = mode == .paused
        
        gradiantHeaderLayer.isHidden = mode == .finishing
        routeeLogo.isHidden = !isReady
        currentLocationStackView.isHidden = !isReady
        moveToUserlocationButton.isHidden = !isReady
        recordButton.isHidden = !isReady
        recordButton.isEnabled = isReady
        workoutMetric.isHidden = !isRecording
        activityButtonStackView.isHidden = !isRecording
        workoutPauseView.isHidden = !isPaused

        if isReady {
            pathOverlay.mapView = nil
            removePhotoMarkers()
            mapView.logoAlign = .leftBottom
            mapView.logoMargin = UIEdgeInsets(
                top: 0,
                left: 30,
                bottom: 144,
                right: 0
            )
        } else {
            mapView.logoAlign = .rightBottom
            mapView.logoMargin = .zero
        }
        
        if !isRecording {
            countdownAnimationView.stop()
            countdownAnimationView.isHidden = true
        }
    }
    
    func playCountdownAnimation() {
        countdownAnimationView.alpha = 1
        countdownAnimationView.currentProgress = 0
        countdownAnimationView.isHidden = false
        countdownAnimationView.play { _ in
            UIView.animate(withDuration: 0.3) {
                self.countdownAnimationView.alpha = 0
            } completion: { _ in
                self.countdownAnimationView.isHidden = true
            }
        }
    }
    
    func playFinishAnimation(completion: @escaping () -> Void) {
        finishAnimationView.alpha = 1
        finishAnimationView.currentProgress = 0
        finishAnimationView.isHidden = false
        bringSubviewToFront(finishAnimationView)
        finishAnimationView.play { [weak self] isFinished in
            guard let self, isFinished else { return }

            finishAnimationView.isHidden = true
            completion()
        }
    }
    
    func addPhotoMarker(_ photoRecord: WorkoutPhotoRecord, at coordinate: CLLocationCoordinate2D) {
        let markerSize = CGSize(width: 42, height: 42)
        let sourceImage = photoRecord.image
        let pointIndex = photoRecord.pointIndex

        Task { [weak self] in
            let thumbnailImage = await Task.detached(priority: .userInitiated) {
                sourceImage
                    .resized(to: markerSize)
                    .thumbnailImage(borderWidth: 3, borderColor: .mint300, cornerRadius: 12)
            }.value

            guard let self else { return }

            let marker = NMFMarker()
            marker.tag = UInt(pointIndex)
            marker.position = NMGLatLng(lat: coordinate.latitude, lng: coordinate.longitude)
            marker.iconImage = NMFOverlayImage(image: thumbnailImage)
            marker.width = markerSize.width
            marker.height = markerSize.height
            marker.anchor = CGPoint(x: 0.5, y: 0.5)
            marker.mapView = mapView
            photoMarkers.append(marker)
        }
    }

    func removePhotoMarkers() {
        photoMarkers.forEach { $0.mapView = nil }
        photoMarkers.removeAll()
    }
}

extension WorkoutView: NMFMapViewCameraDelegate {
    func mapView(_ mapView: NMFMapView, cameraDidChangeByReason reason: Int, animated: Bool) {
        guard mapView.locationOverlay.icon !== userLocationIcon else { return }
        
        applyLocationOverlayStyle()
    }
}
