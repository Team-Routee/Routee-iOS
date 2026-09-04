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
    var photoMarkerTapAction: ((Int) -> Void)?
    
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
    lazy var recordButton = RouteeButton(titleText: "운동 기록", type: .enabled)
    lazy var pauseButton = UIButton()
    lazy var cameraOnButton = UIButton()
    private let cameraIconImageView = UIImageView()
    private let cameraCountLabel = UILabel()
    private let activityButtonStackView = UIStackView()
    private let workoutPauseView = WorkoutPauseView()
    private let photoModalDimView = UIControl()
    private var photoTimelineModal: WorkoutPhotoTimelineModal?
    private var photoModalCenterYConstraint: Constraint?
    private var snackbarView: SnackbarView?
    private var readyLocationBottomConstraint: Constraint?
    private var recordingLocationBottomConstraint: Constraint?
    var restartButton: UIButton { workoutPauseView.restartButton }
    var finishButton: UIButton { workoutPauseView.finishButton }
    
    var mapView: NMFMapView { routeeMapView.mapView }
    private let countdownAnimationView = LottieAnimationView(asset: "countdown")
    private lazy var finishAnimationView = LottieAnimationView(dotLottieAsset: "routeefinish")

    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    // MARK: - UI Setting
    
    override func setUI() {
        addSubviews(
            routeeMapView,
            countdownAnimationView,
            finishAnimationView,
            workoutPauseView,
            photoModalDimView
        )
        
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
        cameraOnButton.addSubviews(cameraIconImageView, cameraCountLabel)
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
            $0.backgroundColor = .mint300
            $0.layer.cornerRadius = 30
            $0.clipsToBounds = true
        }

        cameraIconImageView.do {
            $0.image = UIImage.icCameraFillBlack.withRenderingMode(.alwaysTemplate)
            $0.tintColor = .static_black
            $0.contentMode = .scaleAspectFit
        }

        cameraCountLabel.do {
            $0.text = "0/20"
            $0.font = .label_sb_12
            $0.textColor = .grey_600
            $0.textAlignment = .center
        }
        
        activityButtonStackView.do {
            $0.spacing = 12
            $0.axis = .horizontal
            $0.alignment = .center
        }
        
        workoutPauseView.isHidden = true

        photoModalDimView.do {
            $0.backgroundColor = .dim_secondary
            $0.isHidden = true
        }

        NotificationCenter.default.addObserver(
            self,
            selector: #selector(keyboardWillChangeFrame(_:)),
            name: UIResponder.keyboardWillChangeFrameNotification,
            object: nil
        )
        
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(keyboardWillHide(_:)),
            name: UIResponder.keyboardWillHideNotification,
            object: nil
        )
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

        photoModalDimView.snp.makeConstraints {
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
            $0.centerX.equalToSuperview()
            $0.width.equalTo(343)
        }
        
        currentLocationImage.snp.makeConstraints {
            $0.size.equalTo(24)
        }
        
        moveToUserlocationButton.snp.makeConstraints {
            $0.trailing.equalTo(recordButton)
            readyLocationBottomConstraint = $0.bottom
                .equalTo(recordButton.snp.top)
                .offset(-12)
                .constraint
            recordingLocationBottomConstraint = $0.bottom
                .equalTo(safeAreaLayoutGuide)
                .inset(103)
                .constraint
            $0.size.equalTo(44)
        }
        recordingLocationBottomConstraint?.deactivate()
        
        recordButton.snp.makeConstraints {
            $0.centerX.equalToSuperview()
            $0.bottom.equalTo(safeAreaLayoutGuide).inset(16)
        }
        
        pauseButton.snp.makeConstraints {
            $0.width.equalTo(108)
            $0.height.equalTo(60)
        }
        
        cameraOnButton.snp.makeConstraints {
            $0.size.equalTo(60)
        }

        cameraIconImageView.snp.makeConstraints {
            $0.top.equalToSuperview().inset(12.5)
            $0.centerX.equalToSuperview()
            $0.size.equalTo(24)
        }

        cameraCountLabel.snp.makeConstraints {
            $0.top.equalTo(cameraIconImageView.snp.bottom)
            $0.centerX.equalToSuperview()
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

    func updatePhotoCount(_ count: Int) {
        cameraCountLabel.text = "\(count)/20"
        let isAtPhotoLimit = count >= 20
        cameraOnButton.isEnabled = !isAtPhotoLimit
        cameraOnButton.backgroundColor = isAtPhotoLimit ? .grey200 : .mint300
        cameraIconImageView.tintColor = isAtPhotoLimit ? .grey400 : .static_black
    }

    func showPhotoTimelineModal(
        image: UIImage,
        title: String,
        deleteButtonAction: (() -> Void)? = nil,
        closeButtonAction: ((String) -> Void)? = nil
    ) {
        dismissPhotoTimelineModal()

        let modal = WorkoutPhotoTimelineModal(image: image, title: title)
        modal.deleteButtonAction = deleteButtonAction
        modal.closeButtonAction = { [weak self, weak modal] in
            let updatedTitle = modal?.titleText ?? title
            self?.dismissPhotoTimelineModal()
            closeButtonAction?(updatedTitle)
        }

        photoTimelineModal = modal
        photoModalDimView.isHidden = false
        addSubview(modal)

        modal.snp.makeConstraints {
            $0.centerX.equalToSuperview()
            photoModalCenterYConstraint = $0.centerY.equalToSuperview().constraint
        }
    }

    func dismissPhotoTimelineModal() {
        endEditing(true)
        photoTimelineModal?.removeFromSuperview()
        photoTimelineModal = nil
        photoModalCenterYConstraint = nil
        photoModalDimView.isHidden = true
    }

    func showSnackbar(
        message: String,
        buttonTitle: String,
        buttonAction: @escaping () -> Void
    ) {
        removeSnackbarImmediately()

        let snackbarView = SnackbarView(message: message, buttonTitle: buttonTitle)
        snackbarView.buttonAction = buttonAction
        self.snackbarView = snackbarView
        addSubview(snackbarView)

        snackbarView.snp.makeConstraints {
            $0.centerX.equalToSuperview()
            $0.bottom.equalTo(safeAreaLayoutGuide).inset(CGFloat.s16)
        }
    }

    func dismissSnackbar() async {
        guard let snackbarView else { return }

        snackbarView.isUserInteractionEnabled = false

        await withCheckedContinuation { continuation in
            UIView.animate(withDuration: 0.2) {
                snackbarView.alpha = 0
            } completion: { [weak self] _ in
                snackbarView.removeFromSuperview()
                if self?.snackbarView === snackbarView {
                    self?.snackbarView = nil
                }
                continuation.resume()
            }
        }
    }

    private func removeSnackbarImmediately() {
        snackbarView?.removeFromSuperview()
        snackbarView = nil
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
        hideLocationOverlay()
        pathOverlay.mapView = nil
        removePhotoMarkers()

        if !coordinates.isEmpty {
            let bounds = NMGLatLngBounds(latLngs: coordinates)
            await mapView.moveCamera(NMFCameraUpdate(fit: bounds, padding: 48))
        }

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
        moveToUserlocationButton.isHidden = !(isReady || isRecording)
        if isRecording {
            readyLocationBottomConstraint?.deactivate()
            recordingLocationBottomConstraint?.activate()
        } else {
            recordingLocationBottomConstraint?.deactivate()
            readyLocationBottomConstraint?.activate()
        }
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
        
        if mode != .countdown {
            countdownAnimationView.stop()
            countdownAnimationView.isHidden = true
        }
    }
    
    func playCountdownAnimation(completion: @escaping () -> Void) {
        countdownAnimationView.alpha = 1
        countdownAnimationView.currentProgress = 0
        countdownAnimationView.isHidden = false
        countdownAnimationView.play { [weak self] _ in
            guard let self else { return }

            UIView.animate(withDuration: 0.3) { [weak self] in
                self?.countdownAnimationView.alpha = 0
            } completion: { _ in
                self.countdownAnimationView.isHidden = true
                completion()
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

    func playFinishButtonAnimation() {
        workoutPauseView.playEndingAnimation()
    }

    func stopFinishButtonAnimation() {
        workoutPauseView.stopEndingAnimation()
    }

    func showFinishGuideToast() {
        workoutPauseView.showFinishGuideToast()
    }
    
    func addPhotoMarker(
        _ photoRecord: WorkoutPhotoRecord,
        photoIndex: Int,
        at coordinate: CLLocationCoordinate2D
    ) {
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
            marker.touchHandler = { [weak self] _ in
                self?.photoMarkerTapAction?(photoIndex)
                return true
            }
            marker.mapView = mapView
            photoMarkers.append(marker)
        }
    }

    func removePhotoMarkers() {
        dismissPhotoTimelineModal()
        photoMarkers.forEach { $0.mapView = nil }
        photoMarkers.removeAll()
    }

    @objc
    private func keyboardWillChangeFrame(_ notification: Notification) {
        guard let modal = photoTimelineModal,
              containsFirstResponder(in: modal),
              let keyboardScreenFrame = notification.userInfo?[
                UIResponder.keyboardFrameEndUserInfoKey
              ] as? CGRect else { return }

        layoutIfNeeded()

        let keyboardFrame = convert(keyboardScreenFrame, from: nil)
        let targetModalBottom = min(keyboardFrame.minY, bounds.maxY) - CGFloat.s24
        let targetCenterY = targetModalBottom - modal.bounds.height / 2
        let centerOffset = min(0, targetCenterY - bounds.midY)

        updatePhotoModalCenter(offset: centerOffset, notification: notification)
    }

    @objc
    private func keyboardWillHide(_ notification: Notification) {
        guard photoTimelineModal != nil else { return }

        updatePhotoModalCenter(offset: 0, notification: notification)
    }

    private func updatePhotoModalCenter(offset: CGFloat, notification: Notification) {
        let duration = notification.userInfo?[
            UIResponder.keyboardAnimationDurationUserInfoKey
        ] as? Double ?? 0.25
        let curveRawValue = notification.userInfo?[
            UIResponder.keyboardAnimationCurveUserInfoKey
        ] as? UInt ?? 0
        let curve = UIView.AnimationOptions(rawValue: curveRawValue << 16)

        photoModalCenterYConstraint?.update(offset: offset)
        UIView.animate(
            withDuration: duration,
            delay: 0,
            options: [curve, .beginFromCurrentState]
        ) { [weak self] in
            self?.layoutIfNeeded()
        }
    }

    private func containsFirstResponder(in view: UIView) -> Bool {
        view.isFirstResponder || view.subviews.contains { containsFirstResponder(in: $0) }
    }
}

extension WorkoutView: NMFMapViewCameraDelegate {
    func mapView(_ mapView: NMFMapView, cameraDidChangeByReason reason: Int, animated: Bool) {
        guard mapView.locationOverlay.icon !== userLocationIcon else { return }
        
        applyLocationOverlayStyle()
    }
}
