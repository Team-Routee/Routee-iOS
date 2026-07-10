//
//  WorkoutView.swift
//  Routee-iOS
//
//  Created by LEESANGYUP on 7/8/26.
//

import Combine
import CoreLocation
import UIKit

import NMapsMap
import SnapKit
import Then

final class WorkoutView: BaseUIView {
    
    // MARK: - UI Properties
    
    private let routeeMapView = NMFNaverMapView()
    private let gradiantHeaderLayer = CAGradientLayer()
    private let routeeLogo = UIImageView()
    private let currentLocationStackView = UIStackView()
    private let currentLocationImage = UIImageView()
    private let currentLocationLabel = UILabel()
    private let userLocationIcon = NMFOverlayImage(
        image: UIImage.icNow.resized(to: CGSize(width: 42, height: 42))
    )
    private let pathOverlay = NMFPath()
    
    lazy var moveToUserlocationButton = UIButton(type: .custom)
    lazy var recordButton = RouteeButton(titleText: "등산 기록", type: .enabled)
    
    private var mapView: NMFMapView { routeeMapView.mapView }
    
    // MARK: - UI Setting
    
    override func setUI() {
        addSubview(routeeMapView)
        
        routeeMapView.addSubviews(
            routeeLogo,
            currentLocationStackView,
            moveToUserlocationButton,
            recordButton
        )
        
        routeeMapView.layer.addSublayer(gradiantHeaderLayer)
        
        currentLocationStackView.addArrangedSubviews(currentLocationImage, currentLocationLabel)
    }
    
    override func setStyle() {
        applyLocationOverlayStyle()
        mapSetting()
        
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
    }
    
    override func setLayout() {
        routeeMapView.snp.makeConstraints {
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
            $0.mapView.logoMargin = UIEdgeInsets(
                top: 0,
                left: 30,
                bottom: 144,
                right: 0
            )
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
    
    func setRecording(_ isRecording: Bool) {
        recordButton.setTitle(isRecording ? "기록 종료" : "등산 기록", for: .normal)
    }
    
    // MARK: - Private Methods
    
    private func applyLocationOverlayStyle() {
        mapView.locationOverlay.icon = userLocationIcon
    }
}

extension WorkoutView: NMFMapViewCameraDelegate {
    func mapView(_ mapView: NMFMapView, cameraDidChangeByReason reason: Int, animated: Bool) {
        guard mapView.locationOverlay.icon !== userLocationIcon else { return }
        
        applyLocationOverlayStyle()
    }
}
