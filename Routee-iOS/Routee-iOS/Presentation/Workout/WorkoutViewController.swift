//
//  WorkoutViewController.swift
//  Routee-iOS
//
//  Created by LEESANGYUP on 7/8/26.
//

import CoreLocation
import UIKit

import NMapsMap

final class WorkoutViewController: UIViewController {
    
    // MARK: - Properties
    
    private let workoutView = WorkoutView()
    private let locationManager = CLLocationManager()
    private let reverseGeocodingRepository: ReverseGeocodingRepository
    private var lastReverseGeocodingLocation: CLLocation?
    private var initialLocation = false
    
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
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        navigationController?.setNavigationBarHidden(true, animated: false)
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
    
        func moveToUserLocation() -> Self {
            guard let userLatLng = getUserLocation() else { return self }
            
            let cameraUpdate = NMFCameraUpdate(scrollTo: userLatLng)
            
            DispatchQueue.main.async { [weak self] in
                cameraUpdate.animation = .easeIn
                self?.workoutView.mapView.moveCamera(cameraUpdate)
            }
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
            let cameraUpdate = NMFCameraUpdate(scrollTo: location)
            DispatchQueue.main.async { [weak self] in
                cameraUpdate.animation = .easeIn
                self?.workoutView.mapView.moveCamera(cameraUpdate)
            }
            return self
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
