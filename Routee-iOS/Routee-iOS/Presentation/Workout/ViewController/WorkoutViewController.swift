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
}

final class WorkoutViewController: BaseUIViewController {
    
    // MARK: - Properties
    
    private let workoutView = WorkoutView()
    private var workoutMode: WorkoutMode = .ready {
        didSet {
            guard oldValue != workoutMode else { return }
            updateUI(for: workoutMode)
        }
    }
    private let viewModel = WorkoutViewModel()
    private let locationManager = CLLocationManager()
    private var initialLocation = false
    private var lastReverseGeocodingLocation: CLLocation?
    private var lastRecordedLocation: CLLocation?
    private var routeLocations: [NMGLatLng] = []
    
    // MARK: - Life Cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setLocationManager()
        updateUI(for: workoutMode)
    }

    override func loadView() {
        view = workoutView
    }
    
    // MARK: - Private Methods
    
    private func updateUI(for mode: WorkoutMode) {
        workoutView.configure(for: mode)
        let shouldHideTabBar = mode != .ready
        (tabBarController as? TabBarViewController)?.setCustomTabBarHidden(shouldHideTabBar)
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
        guard workoutMode == .recording else { return }
        
        let currentLatLng = NMGLatLng(
            lat: location.coordinate.latitude,
            lng: location.coordinate.longitude
        )
        
        lastRecordedLocation = location
        routeLocations.append(currentLatLng)
        workoutView.updateRoutePath(routeLocations)
    }
    
    private func startRecordingRoute() {
        workoutMode = .recording
        workoutView.playCountdown()
        lastRecordedLocation = nil
        routeLocations.removeAll()
        workoutView.updateRoutePath(routeLocations)
        
        if let currentLocation = locationManager.location {
            appendRouteLocationIfNeeded(currentLocation)
        }
    }
    
    private func pauseRecordingRoute() {
        workoutMode = .paused
    }

    private func resumeRecordingRoute() {
        workoutMode = .recording
    }

    private func finishRecordingRoute() {
        workoutMode = .ready
        lastRecordedLocation = nil
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

    private func pushPhotoLocationViewController(image: UIImage) {
        let viewController = WorkoutPhotoLocationViewController(image: image)
        navigationController?.pushViewController(viewController, animated: true)
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
    
    // MARK: - Actions
    
    override func setAddTarget() {
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

        workoutView.puaseButton.addTarget(
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

        workoutView.cameraOnButton.addTarget(
            self,
            action: #selector(didTapCameraButton),
            for: .touchUpInside
        )
    }
    
    @objc
    private func didTapRecordButton() {
        startRecordingRoute()
    }

    @objc
    private func didTapPauseButton() {
        pauseRecordingRoute()
    }

    @objc
    private func didTapRestartButton() {
        resumeRecordingRoute()
    }

    @objc
    private func didTapFinishButton() {
        finishRecordingRoute()
    }

    @objc
    private func didTapCameraButton() {
        requestCameraAccess()
    }
    
    @objc
    func locationButtonDidTap() {
        workoutView.focusOnUserDirection()
    }
}

// MARK: - CLLocationManagerDelegate

extension WorkoutViewController: CLLocationManagerDelegate {
    private func setLocationManager() {
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
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

// MARK: - UIImagePickerControllerDelegate

extension WorkoutViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    func imagePickerController(
        _ picker: UIImagePickerController,
        didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]
    ) {
        guard let image = info[.originalImage] as? UIImage else {
            picker.dismiss(animated: true)
            return
        }

        picker.dismiss(animated: true) { [weak self] in
            self?.pushPhotoLocationViewController(image: image)
        }
    }

    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true)
    }
}
