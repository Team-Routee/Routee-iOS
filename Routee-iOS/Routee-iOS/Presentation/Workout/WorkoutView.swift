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
    
    // MARK: - Properties
    
    @Published var pathDistance: Double = 0
    
    private let screenWidth = UIScreen.main.bounds.width
    private let screenHeight = UIScreen.main.bounds.height
    
    let pathImage = PassthroughSubject<UIImage?, Never>()
    private var cancelBag = Set<AnyCancellable>()
    
    private let locationManager = CLLocationManager()
    private var isDrawMode: Bool = false
    private var bottomPadding: CGFloat = 0
    private let locationOverlayIcon = NMFOverlayImage(
        image: UIImage.icNow.resized(to: CGSize(width: 42, height: 42))
    )
    private let gradiantHeaderLayer = CAGradientLayer()
    
    // MARK: - UI Properties
    
    private let routeeMapView = NMFNaverMapView()
    private let gradiantHeaderView = UIView()
    private let routeeLogo = UIImageView()
    private let currentLocationImage = UIImageView()
    private let currentLocationLabel = UILabel()
    private let currentLocationStackView = UIStackView()
    private let pathOverlay = NMFPath()
    private let moveToUserlocationButton = UIButton(type: .custom)
    private lazy var recordButton = RouteeButton(titleText: "등산 기록", type: .enabled)
    
    var mapView: NMFMapView {
        routeeMapView.mapView
    }
    
    override func setUI() {
        addSubview(routeeMapView)
        
        routeeMapView.addSubviews(
            gradiantHeaderView,
            routeeLogo,
            currentLocationStackView,
            moveToUserlocationButton,
            recordButton
        )
        
        currentLocationStackView.addArrangedSubviews(
            currentLocationImage,
            currentLocationLabel
        )
    }
    
    override func setStyle() {
        applyLocationOverlayStyle()
        mapSetting()
        
        gradiantHeaderView.do {
            $0.isUserInteractionEnabled = false
            $0.layer.addSublayer(gradiantHeaderLayer)
        }
        
        gradiantHeaderLayer.do {
            $0.colors = [
                UIColor.grey_900.cgColor,
                UIColor.grey_900.withAlphaComponent(0).cgColor
            ]
            $0.locations = [0, 1]
            $0.startPoint = CGPoint(x: 0, y: 0.15)
            $0.endPoint = CGPoint(x: 0, y: 1)
        }
        
        routeeLogo.do {
            $0.image = .routeeLogoMintMd
            $0.contentMode = .scaleAspectFit
        }
        
        currentLocationImage.do {
            $0.image = .icLocationInfoSmGradient
            $0.contentMode = .scaleAspectFit
        }
        
        currentLocationLabel.do {
            $0.text = "영등포구 의사당대로"
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
        }
        
        moveToUserlocationButton.do {
            $0.setImage(.icInplace, for: .normal)
            $0.backgroundColor = .static_black
            $0.layer.cornerRadius = 22
            $0.clipsToBounds = true
            $0.isHidden = false
            $0.addTarget(self, action: #selector(locationButtonDidTap), for: .touchUpInside)
        }
    }
    
    private func updateSubviewsConstraints() {
        [moveToUserlocationButton].forEach { view in
            view.snp.updateConstraints { make in
                make.bottom.equalToSuperview().inset(98 + bottomPadding)
            }
        }
    }
    
    override func setLayout() {
        routeeMapView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
        
        gradiantHeaderView.snp.makeConstraints {
            $0.top.equalToSuperview()
            $0.centerX.equalToSuperview()
            $0.height.equalTo(141)
            $0.horizontalEdges.equalToSuperview()
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
        
        gradiantHeaderLayer.frame = gradiantHeaderView.bounds
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
    
    @objc
    func locationButtonDidTap() {
        mapView.positionMode = .direction
        applyLocationOverlayStyle()
    }
    
    func applyLocationOverlayStyle() {
        let locationOverlay = mapView.locationOverlay
        locationOverlay.icon = locationOverlayIcon
    }
}

extension WorkoutView: NMFMapViewCameraDelegate {
    func mapView(_ mapView: NMFMapView, cameraDidChangeByReason reason: Int, animated: Bool) {
        guard mapView.locationOverlay.icon !== locationOverlayIcon else { return }
        
        applyLocationOverlayStyle()
    }
}
