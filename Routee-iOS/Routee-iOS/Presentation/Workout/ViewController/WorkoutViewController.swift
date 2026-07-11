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
    private let viewModel = WorkoutViewModel()
    private let locationManager = CLLocationManager()
    private var initialLocation = false
    private var isRecordingRoute = false
    private var lastReverseGeocodingLocation: CLLocation?
    private var lastRecordedLocation: CLLocation?
    private var routeLocations: [NMGLatLng] = []
    
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
        guard isRecordingRoute else { return }
        
        let currentLatLng = NMGLatLng(
            lat: location.coordinate.latitude,
            lng: location.coordinate.longitude
        )
        
        lastRecordedLocation = location
        routeLocations.append(currentLatLng)
        workoutView.updateRoutePath(routeLocations)
    }
    
    private func startRecordingRoute() {
        isRecordingRoute = true
        lastRecordedLocation = nil
        routeLocations.removeAll()
        workoutView.updateRoutePath(routeLocations)
        workoutView.setRecording(true)
        
        if let currentLocation = locationManager.location {
            appendRouteLocationIfNeeded(currentLocation)
        }
    }
    
    private func stopRecordingRoute() {
        isRecordingRoute = false
        workoutView.setRecording(false)
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
    }
    
    @objc
    private func didTapRecordButton() {
        if isRecordingRoute {
            stopRecordingRoute()
        } else {
            startRecordingRoute()
        }
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
