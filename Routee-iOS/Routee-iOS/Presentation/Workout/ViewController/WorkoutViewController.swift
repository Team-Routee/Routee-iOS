//
//  WorkoutViewController.swift
//  Routee-iOS
//
//  Created by LEESANGYUP on 7/8/26.
//

import AVFoundation
import CoreLocation
import UIKit

import NMapsMap

enum WorkoutMode: Equatable {
    case ready
    case recording
    case paused
    case finishing
}

final class WorkoutViewController: BaseUIViewController {
    
    // MARK: - Properties
    
    let workoutView = WorkoutView()
    private var workoutMode: WorkoutMode = .ready {
        didSet {
            guard oldValue != workoutMode else { return }
            updateUI(for: workoutMode)
            updateElapsedTimeTracking(from: oldValue, to: workoutMode)
            updateBackgroundLocationTracking(for: workoutMode)
        }
    }
    let viewModel = WorkoutViewModel()
    private let locationManager = CLLocationManager()
    private var initialLocation = false
    private var lastReverseGeocodingLocation: CLLocation?
    private let hapticManager = HapticManager()
    private var pendingTimelineDeletionTask: Task<Void, Never>?
    private var photoUploadTasks: [Int: Task<Void, Never>] = [:]
    private var timelineTitleUpdateTasks: [Int: Task<Void, Never>] = [:]
    
    // MARK: - Life Cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()

        bindViewModel()
        setLocationManager()
        updateUI(for: workoutMode)
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        if workoutMode == .finishing {
            workoutMode = .ready
            requestCurrentLocationAuthorization()
            moveCameraToCurrentLocation()
        }
    }
    
    override func loadView() {
        view = workoutView
    }
    
    // MARK: - Private Methods
    
    private func updateUI(for mode: WorkoutMode) {
        workoutView.configure(for: mode)
        (tabBarController as? TabBarViewController)?.setCustomTabBarHidden(mode != .ready)
    }
    
    private func requestCurrentLocationAuthorization() {
        switch locationManager.authorizationStatus {
        case .notDetermined:
            locationManager.requestWhenInUseAuthorization()
        case .authorizedAlways, .authorizedWhenInUse:
            startShowingCurrentLocation()
        case .denied, .restricted:
            stopShowingCurrentLocation()
        default:
            stopShowingCurrentLocation()
        }
    }
    
    private func moveCameraToCurrentLocation() {
        guard let location = locationManager.location else { return }

        let currentLatLng = NMGLatLng(
            lat: location.coordinate.latitude,
            lng: location.coordinate.longitude
        )
        workoutView.moveCamera(to: currentLatLng, zoomTo: 16)
    }

    private func startShowingCurrentLocation() {
        workoutView.showLocationOverlay()
        locationManager.startUpdatingLocation()
        locationManager.requestLocation()
    }
    
    private func stopShowingCurrentLocation() {
        workoutView.hideLocationOverlay()
        locationManager.stopUpdatingLocation()
    }
    
    private func updateCurrentLocation(_ location: CLLocation) {
        let currentLatLng = NMGLatLng(
            lat: location.coordinate.latitude,
            lng: location.coordinate.longitude
        )
        
        workoutView.updateUserLocation(currentLatLng, course: location.course)
        appendRouteLocationIfNeeded(location)
        updateCurrentAddress(location)
        
        guard !initialLocation else { return }
        
        initialLocation = true
        workoutView.moveCamera(to: currentLatLng, zoomTo: 16)
    }
    
    private func appendRouteLocationIfNeeded(_ location: CLLocation) {
        guard workoutMode == .recording,
              let totalDistance = viewModel.recordDistance(at: location) else { return }
        
        workoutView.updateRoutePath(viewModel.routePoints.map(\.latLng))
        workoutView.updateDistance(totalDistance)
    }
    
    private func pauseRecordingRoute() {
        workoutMode = .paused
        viewModel.pauseDistanceTracking()
        workoutView.setFinishButtonEnabled(viewModel.canFinishRecording)
        changeActivityStatus(to: "ACTIVITY_PAUSED")
    }

    private func resumeRecordingRoute() {
        workoutMode = .recording
        changeActivityStatus(to: "ACTIVITY_IN_PROGRESS")
    }
    
    private func finishRecordingRoute() {
        guard
            workoutMode != .finishing,
            viewModel.canFinishRecording
        else { return }
        workoutMode = .finishing

        let backgroundMapTask = Task { () -> UIImage? in
            guard let mapImage = await workoutView.captureBackgroundMapImage(
                fitting: viewModel.routePoints.map(\.latLng)
            ) else { return nil }

            do {
                try await viewModel.uploadBackgroundMap(image: mapImage)
            } catch {
                RouteeLogger.error(error)
            }
            return mapImage
        }

        workoutView.playFinishAnimation { [weak self] in
            guard let self else { return }

            Task {
                let mapImage = await backgroundMapTask.value
                await MainActor.run {
                    self.pushWorkoutTimeLineViewController(backgroundMapImage: mapImage)
                }
            }
        }
    }

    private func pushWorkoutTimeLineViewController(backgroundMapImage: UIImage?) {
        let viewController = WorkoutTimeLineViewController(
            activityId: viewModel.activityId,
            title: viewModel.activityTitle ?? "",
            distanceInMeters: viewModel.totalDistance,
            durationInSeconds: viewModel.elapsedTimeInSeconds,
            maxAltitudeInMeters: viewModel.maximumAltitudeInMeters,
            backgroundMapImage: backgroundMapImage,
            trackPoints: viewModel.routePoints.map {
                TrackPoint(latitude: $0.coordinate.latitude, longitude: $0.coordinate.longitude)
            },
            photoRecords: viewModel.photoRecords,
            finishRecording: { [viewModel] title in
                try await viewModel.finishRecording(title: title)
            }
        )
        navigationController?.pushViewController(viewController, animated: true)
    }
    
    private func requestCameraAccess() {
        guard UIImagePickerController.isSourceTypeAvailable(.camera) else {
            showCameraUnavailableAlert()
            return
        }
        
        switch AVCaptureDevice.authorizationStatus(for: .video) {
        case .authorized:
            presentCamera()
        case .notDetermined:
            AVCaptureDevice.requestAccess(for: .video) { [weak self] isGranted in
                DispatchQueue.main.async {
                    if isGranted {
                        self?.presentCamera()
                    } else {
                        self?.showCameraPermissionAlert()
                    }
                }
            }
        case .denied, .restricted:
            showCameraPermissionAlert()
        @unknown default:
            showCameraPermissionAlert()
        }
    }
    
    private func presentCamera() {
        let imagePickerController = UIImagePickerController()
        imagePickerController.sourceType = .camera
        imagePickerController.cameraCaptureMode = .photo
        imagePickerController.delegate = self
        imagePickerController.modalPresentationStyle = .fullScreen
        present(imagePickerController, animated: true)
    }
    
    private func showCameraUnavailableAlert() {
        let alert = UIAlertController(
            title: "카메라를 사용할 수 없어요",
            message: "카메라를 지원하는 기기에서 다시 시도해주세요.",
            preferredStyle: .alert
        )
        alert.addAction(UIAlertAction(title: "확인", style: .default))
        present(alert, animated: true)
    }
    
    private func showCameraPermissionAlert() {
        let alert = UIAlertController(
            title: "카메라 권한이 필요해요",
            message: "설정에서 카메라 접근을 허용해주세요.",
            preferredStyle: .alert
        )
        alert.addAction(UIAlertAction(title: "취소", style: .cancel))
        alert.addAction(UIAlertAction(title: "설정으로 이동", style: .default) { _ in
            guard let settingsURL = URL(string: UIApplication.openSettingsURLString) else { return }
            UIApplication.shared.open(settingsURL)
        })
        present(alert, animated: true)
    }
    
    private func updateCurrentAddress(_ location: CLLocation) {
        if let lastReverseGeocodingLocation,
           location.distance(from: lastReverseGeocodingLocation) < 50 {
            return
        }
        
        lastReverseGeocodingLocation = location
        
        Task { [weak self] in
            guard let self else { return }
            
            do {
                guard let address = try await viewModel.currentAddress(for: location) else {
                    return
                }
                
                await MainActor.run {
                    self.workoutView.updateCurrentLocationAddress(address)
                }
            } catch {
                RouteeLogger.error(error)
            }
        }
    }
    
    func moveToUserLocation() -> Self {
        guard let userLatLng = getUserLocation() else { return self }
        
        workoutView.moveCamera(to: userLatLng)
        return self
    }
    
    func getUserLocation() -> NMGLatLng? {
        guard let userLocation = locationManager.location?.coordinate else { return nil }
        
        return NMGLatLng(
            lat: userLocation.latitude,
            lng: userLocation.longitude
        )
    }
    
    @discardableResult
    func moveToLocation(location: NMGLatLng) -> Self {
        workoutView.moveCamera(to: location)
        return self
    }
    
    private func currentStartedAt() -> String {
            let formatter = DateFormatter()
            formatter.calendar = Calendar(identifier: .gregorian)
            formatter.locale = Locale(identifier: "en_US_POSIX")
            formatter.timeZone = .current
            formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss"
            return formatter.string(from: Date())
        }
    
    // MARK: - Actions
    
    override func setAddTarget() {
        workoutView.photoMarkerTapAction = { [weak self] photoIndex in
            self?.showPhotoTimelineModal(at: photoIndex)
        }

        workoutView.recordButton.addTarget(
            self,
            action: #selector(didTapRecordButton),
            for: .touchUpInside
        )
        
        workoutView.moveToUserlocationButton.addTarget(
            self,
            action: #selector(locationButtonDidTap),
            for: .touchUpInside
        )
        
        workoutView.pauseButton.addTarget(
            self,
            action: #selector(didTapPauseButton),
            for: .touchUpInside
        )
        
        workoutView.restartButton.addTarget(
            self,
            action: #selector(didTapRestartButton),
            for: .touchUpInside
        )
        
        workoutView.finishButton.addTarget(
            self,
            action: #selector(didTapFinishButton),
            for: .touchUpInside
        )
        
        workoutView.finishButton.addTarget(
            self,
            action: #selector(didTouchDownFinishButton),
            for: .touchDown
        )
        
        workoutView.finishButton.addTarget(
            self,
            action: #selector(didEndPressFinishButton),
            for: [.touchUpInside, .touchUpOutside, .touchCancel]
        )
        
        let finishLongPressGesture = UILongPressGestureRecognizer(
            target: self,
            action: #selector(didLongPressFinishButton(_:))
        )
        finishLongPressGesture.minimumPressDuration = 1.5
        workoutView.finishButton.addGestureRecognizer(finishLongPressGesture)
        
        workoutView.cameraOnButton.addTarget(
            self,
            action: #selector(didTapCameraButton),
            for: .touchUpInside
        )
    }
    
    @objc
    private func didTapRecordButton() {
        startRecording()
    }
    
    @objc
    private func didTapPauseButton() {
        pauseRecordingRoute()
    }
    
    @objc
    private func didTapRestartButton() {
        resumeRecordingRoute()
        let generator = UIImpactFeedbackGenerator(style: .light)
        generator.impactOccurred()
    }
    
    @objc
    private func didTapFinishButton() {
        workoutView.showFinishGuideToast()
        let generator = UIImpactFeedbackGenerator(style: .rigid)
        generator.impactOccurred()
    }

    @objc
    private func didTouchDownFinishButton() {
        hapticManager.play(.workoutFinished)
        workoutView.playFinishButtonAnimation()
    }

    @objc
    private func didEndPressFinishButton() {
        hapticManager.stop()
        workoutView.stopFinishButtonAnimation()
    }
    
    @objc
    private func didLongPressFinishButton(_ gesture: UILongPressGestureRecognizer) {
        guard gesture.state == .began else { return }

        finishRecordingRoute()
    }
    
    @objc
    private func didTapCameraButton() {
        guard pendingTimelineDeletionTask == nil else { return }
        requestCameraAccess()
    }

    private func showPhotoTimelineModal(at photoIndex: Int) {
        guard viewModel.photoRecords.indices.contains(photoIndex) else { return }

        let photoRecord = viewModel.photoRecords[photoIndex]
        workoutView.showPhotoTimelineModal(
            image: photoRecord.image,
            title: photoRecord.locationTitle ?? "",
            deleteButtonAction: { [weak self] in
                self?.deleteTimeline(at: photoIndex)
            },
            closeButtonAction: { [weak self] updatedTitle in
                self?.updateTimelineTitle(at: photoIndex, title: updatedTitle)
            }
        )
    }

    private func updateTimelineTitle(at photoIndex: Int, title: String) {
        let normalizedTitle = title.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !normalizedTitle.isEmpty,
              viewModel.photoRecords.indices.contains(photoIndex),
              viewModel.photoRecords[photoIndex].locationTitle != normalizedTitle else { return }

        let updateTask = Task { [weak self] in
            guard let self else { return }

            await photoUploadTasks[photoIndex]?.value

            do {
                try await viewModel.updateTimelineTitle(
                    at: photoIndex,
                    title: normalizedTitle
                )
            } catch {
                RouteeLogger.error(error)
            }
        }
        timelineTitleUpdateTasks[photoIndex] = updateTask
    }

    private func deleteTimeline(at photoIndex: Int) {
        guard pendingTimelineDeletionTask == nil,
              viewModel.photoRecords.indices.contains(photoIndex) else { return }

        workoutView.dismissPhotoTimelineModal()
        reloadPhotoMarkers(excluding: photoIndex)
        workoutView.showSnackbar(
            message: "삭제되었습니다",
            buttonTitle: "취소"
        ) { [weak self] in
            self?.cancelTimelineDeletion()
        }

        pendingTimelineDeletionTask = Task { [weak self] in
            try? await Task.sleep(for: .seconds(2))
            guard !Task.isCancelled, let self else { return }

            await workoutView.dismissSnackbar()

            let uploadTasks = Array(photoUploadTasks.values)
            for uploadTask in uploadTasks {
                await uploadTask.value
            }
            photoUploadTasks.removeAll()

            let titleUpdateTasks = Array(timelineTitleUpdateTasks.values)
            for titleUpdateTask in titleUpdateTasks {
                await titleUpdateTask.value
            }
            timelineTitleUpdateTasks.removeAll()

            do {
                try await viewModel.deleteTimeline(at: photoIndex)
            } catch {
                RouteeLogger.error(error)
            }

            pendingTimelineDeletionTask = nil
            reloadPhotoMarkers()
        }
    }

    private func cancelTimelineDeletion() {
        pendingTimelineDeletionTask?.cancel()
        pendingTimelineDeletionTask = nil

        Task { [weak self] in
            guard let self else { return }

            await workoutView.dismissSnackbar()
            reloadPhotoMarkers()
        }
    }

    private func reloadPhotoMarkers(excluding excludedPhotoIndex: Int? = nil) {
        workoutView.removePhotoMarkers()

        viewModel.photoRecords.enumerated().forEach { photoIndex, photoRecord in
            guard photoIndex != excludedPhotoIndex else { return }
            guard let routePoint = viewModel.routePoint(matching: photoRecord.pointIndex) else { return }

            workoutView.addPhotoMarker(
                photoRecord,
                photoIndex: photoIndex,
                at: routePoint.coordinate
            )
        }
    }
    
    @objc
    func locationButtonDidTap() {
        workoutView.focusOnUserDirection()
    }
    
    // MARK: - Network

    private func changeActivityStatus(to status: String) {
        Task {
            do {
                try await viewModel.changeActivityStatus(status)
            } catch {
                RouteeLogger.error(error)
            }
        }
    }

    private func startRecording() {
        guard workoutMode == .ready, workoutView.recordButton.isEnabled else { return }

        let startedAt = currentStartedAt()
        workoutView.recordButton.isEnabled = false

        Task {
            do {
                let activity = try await viewModel.startRecording(
                    activityType: "HIKING",
                    startedAt: startedAt
                )

                RouteeLogger.debug("운동 기록 시작 완료 (activityId: \(activity.activityId))")
                await MainActor.run {
                    self.workoutMode = .recording
                    self.workoutView.playCountdownAnimation()
                    self.workoutView.updateDistance(self.viewModel.startDistanceTracking())
                    self.workoutView.updateRoutePath(self.viewModel.routePoints.map(\.latLng))

                    if let currentLocation = self.locationManager.location {
                        self.appendRouteLocationIfNeeded(currentLocation)
                    }
                }
            } catch {
                await MainActor.run {
                    self.workoutView.recordButton.isEnabled = true
                }
                RouteeLogger.error(error)
            }
        }
    }
}

extension WorkoutViewController {
    private func bindViewModel() {
        viewModel.elapsedTimeDidChange = { [weak self] in self?.workoutView.updateElapsedTime($0) }
        viewModel.maximumAltitudeDidChange = { [weak self] in self?.workoutView.updateMaximumAltitude($0) }
    }

    private func updateElapsedTimeTracking(from oldMode: WorkoutMode, to newMode: WorkoutMode) {
        switch (oldMode, newMode) {
        case (.ready, .recording):
            viewModel.startElapsedTimeTracking()
        case (.paused, .recording):
            viewModel.resumeElapsedTimeTracking()
        case (_, .paused), (_, .finishing):
            viewModel.pauseElapsedTimeTracking()
        default:
            break
        }
    }

    private func updateBackgroundLocationTracking(for mode: WorkoutMode) {
        locationManager.allowsBackgroundLocationUpdates = mode == .recording
    }
}

// MARK: - Extensions

extension WorkoutViewController: CLLocationManagerDelegate {
    private func setLocationManager() {
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.distanceFilter = 3
        locationManager.activityType = .fitness
        locationManager.allowsBackgroundLocationUpdates = false
        requestCurrentLocationAuthorization()
    }
    
    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        requestCurrentLocationAuthorization()
    }
    
    func locationManager(
        _ manager: CLLocationManager,
        didUpdateLocations locations: [CLLocation]
    ) {
        guard let location = locations.last else { return }
        
        updateCurrentLocation(location)
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) { }
}

// MARK: - Extensions

extension WorkoutViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    func imagePickerController(
        _ picker: UIImagePickerController,
        didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]
    ) {
        guard let image = info[.originalImage] as? UIImage,
              let pointIndex = viewModel.routePoints.last?.pointIndex else {
            picker.dismiss(animated: true)
            return
        }

        let photoRecord = WorkoutPhotoRecord(image: image, pointIndex: pointIndex)
        picker.dismiss(animated: true) { [weak self] in
            self?.pushPhotoLocationViewController(photoRecord: photoRecord)
        }
    }

    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true)
    }

    private func pushPhotoLocationViewController(photoRecord: WorkoutPhotoRecord) {
        let viewController = WorkoutPhotoLocationViewController(image: photoRecord.image) { [weak self] title in
            self?.savePhotoRecord(photoRecord, title: title)
        }
        navigationController?.pushViewController(viewController, animated: true)
    }

    private func savePhotoRecord(_ photoRecord: WorkoutPhotoRecord, title: String) {
        guard let routePoint = viewModel.routePoint(matching: photoRecord.pointIndex) else { return }

        let photoIndex = viewModel.savePhotoRecord(photoRecord, title: title)
        workoutView.addPhotoMarker(
            photoRecord,
            photoIndex: photoIndex,
            at: routePoint.coordinate
        )

        let uploadTask = Task { [weak self] in
            guard let self else { return }

            do {
                try await viewModel.uploadPhoto(at: photoIndex)
            } catch {
                RouteeLogger.error(error)
            }
        }
        photoUploadTasks[photoIndex] = uploadTask
    }
}
