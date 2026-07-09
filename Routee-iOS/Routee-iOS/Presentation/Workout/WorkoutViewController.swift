//
//  WorkoutViewController.swift
//  Routee-iOS
//
//  Created by LEESANGYUP on 7/8/26.
//

import CoreLocation
import UIKit

import NMapsMap

final class WorkoutViewController: BaseUIViewController {
    
    // MARK: - Properties
    
    private let workoutView = WorkoutView()
    private let locationManager = CLLocationManager()
    private let reverseGeocodingRepository: ReverseGeocodingRepository
    private var lastReverseGeocodingLocation: CLLocation?
    private var initialLocation = false
    private var isRecordingRoute = false
    private var routeLocations: [NMGLatLng] = []
    
    init(reverseGeocodingRepository: ReverseGeocodingRepository = DefaultReverseGeocodingRepository()) {
        self.reverseGeocodingRepository = reverseGeocodingRepository
        super.init(nibName: nil, bundle: nil)
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        nil
    }
    
    // MARK: - Life Cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setLocationManager()
    }
    
    override func loadView() {
        view = workoutView
    }
    
    // MARK: - Private Methods
    
    private func requestCurrentLocationAuthorization() {
        switch locationManager.authorizationStatus {
        case .notDetermined:
            locationManager.requestWhenInUseAuthorization()
        case .authorizedAlways, .authorizedWhenInUse:
            startShowingCurrentLocation()
        case .denied, .restricted:
            stopShowingCurrentLocation()
        @unknown default:
            stopShowingCurrentLocation()
        }
    }
    
    private func startShowingCurrentLocation() {
        workoutView.mapView.locationOverlay.hidden = false
        workoutView.mapView.positionMode = .direction
        workoutView.applyLocationOverlayStyle()
        locationManager.startUpdatingLocation()
        locationManager.requestLocation()
    }
    
    private func stopShowingCurrentLocation() {
        workoutView.mapView.locationOverlay.hidden = true
        workoutView.mapView.positionMode = .disabled
        locationManager.stopUpdatingLocation()
    }
    
    private func updateCurrentLocation(_ location: CLLocation) {
        let currentLatLng = NMGLatLng(
            lat: location.coordinate.latitude,
            lng: location.coordinate.longitude
        )
        
        workoutView.mapView.locationOverlay.location = currentLatLng
        workoutView.applyLocationOverlayStyle()
        appendRouteLocationIfNeeded(currentLatLng)
        updateCurrentAddressIfNeeded(location)
        
        if location.course >= 0 {
            workoutView.mapView.locationOverlay.heading = location.course
        }
        
        guard !initialLocation else { return }
        
        initialLocation = true
        let cameraUpdate = NMFCameraUpdate(scrollTo: currentLatLng, zoomTo: 16)
        cameraUpdate.animation = .easeIn
        workoutView.mapView.moveCamera(cameraUpdate)
    }
    
    private func appendRouteLocationIfNeeded(_ location: NMGLatLng) {
        guard isRecordingRoute else { return }
        
        routeLocations.append(location)
        workoutView.updateRoutePath(routeLocations)
    }
    
    private func updateCurrentAddressIfNeeded(_ location: CLLocation) {
        if let lastReverseGeocodingLocation,
           location.distance(from: lastReverseGeocodingLocation) < 50 {
            return
        }
        
        lastReverseGeocodingLocation = location
        
        Task { [weak self] in
            guard let self else { return }
            
            do {
                let address = try await reverseGeocodingRepository.roadAddress(
                    latitude: location.coordinate.latitude,
                    longitude: location.coordinate.longitude
                )
                
                await MainActor.run {
                    self.workoutView.updateCurrentLocationAddress(address)
                }
            } catch {
                RouteeLogger.error(error)
            }
        }
    }
    
    private func moveToUserLocation() {
        guard let userLatLng = getUserLocation() else {
            locationManager.requestLocation()
            return
        }
        
        moveToLocation(userLatLng)
    }
    
    private func getUserLocation() -> NMGLatLng? {
        guard let userLocation = locationManager.location?.coordinate else { return nil }
        
        return NMGLatLng(
            lat: userLocation.latitude,
            lng: userLocation.longitude
        )
    }
    
    private func moveToLocation(_ location: NMGLatLng) {
        let cameraUpdate = NMFCameraUpdate(scrollTo: location)
        cameraUpdate.animation = .easeIn
        workoutView.mapView.moveCamera(cameraUpdate)
    }
    
    // MARK: - Actions
    
    override func setAddTarget() {
        workoutView.moveToUserlocationButton.addTarget(
            self,
            action: #selector(didTapMoveToUserLocationButton),
            for: .touchUpInside
        )
        workoutView.recordButton.addTarget(self, action: #selector(recordButtonDidTap), for: .touchUpInside)
    }
    
    @objc
    private func didTapMoveToUserLocationButton() {
        switch locationManager.authorizationStatus {
        case .notDetermined:
            locationManager.requestWhenInUseAuthorization()
        case .authorizedAlways, .authorizedWhenInUse:
            startShowingCurrentLocation()
            moveToUserLocation()
        case .denied, .restricted:
            stopShowingCurrentLocation()
        @unknown default:
            stopShowingCurrentLocation()
        }
    }
    
    @objc
    private func recordButtonDidTap() {
        isRecordingRoute = true
        routeLocations.removeAll()
        
        if let userLocation = getUserLocation() {
            routeLocations.append(userLocation)
            workoutView.updateRoutePath(routeLocations)
        } else {
            locationManager.requestLocation()
        }
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
