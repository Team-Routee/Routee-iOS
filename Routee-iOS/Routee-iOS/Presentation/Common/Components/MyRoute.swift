//
//  RouteView.swift
//  Routee-iOS
//
//  Created by 초긍정행운의포춘쿠키 on 7/11/26.
//

import UIKit

import SnapKit
import Then

enum RouteViewMode {
    case read
    case write
}

struct RoutePointModel {
    let points: [String]
}

enum RoutePointDummyData {
    static let routePoints = RoutePointModel(
        points: [
            "창의문",
            "청운대",
            "말바위",
            "이승희"
        ]
    )
}

final class MyRoute: BaseUIView {
    
    // MARK: - UI Properties
    
    private let myRouteLabel = UILabel()
    private let countRouteLabel = UILabel()
    private let toggleButton = UIButton(type: .custom)
    private let routeStackView = UIStackView()
    private let addRouteButton = UIButton(type: .custom)
    
    // MARK: - Properties
    
    private let maxPointCount = 12
    private let collapsedPointCount = 3
    private var mode: RouteViewMode
    private var routePoint: RoutePointModel
    private var isExpanded = false
    
    // MARK: - Initializer
    
    init(mode: RouteViewMode) {
        self.mode = mode
        self.routePoint = Self.defaultRoutePoint()
        super.init(frame: .zero)
        updateView()
    }
    
    override init(frame: CGRect) {
        self.mode = .read
        self.routePoint = Self.defaultRoutePoint()
        super.init(frame: frame)
        updateView()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - UI Setting
    
    override func setStyle() {
        backgroundColor = .clear
        
        myRouteLabel.do {
            $0.text = "나의 루트"
            $0.font = .title_sb_18
            $0.textColor = .static_white
        }
        
        countRouteLabel.do {
            $0.font = .label_m_14
            $0.textColor = .grey_300
        }
        
        toggleButton.do {
            $0.setImage(.icArrowDownWhite, for: .normal)
            $0.setImage(.icArrowDownWhite, for: .highlighted)
            $0.tintColor = .static_white
            $0.addTarget(self, action: #selector(toggleButtonDidTap), for: .touchUpInside)
        }
        
        routeStackView.do {
            $0.axis = .vertical
            $0.alignment = .fill
            $0.distribution = .fill
            $0.spacing = 0
        }
        
        addRouteButton.do {
            var configuration = UIButton.Configuration.plain()
            configuration.image = .icPlusCircleSmMint
            configuration.imagePadding = 6
            configuration.baseForegroundColor = .static_white
            configuration.attributedTitle = AttributedString(
                "지점 추가",
                attributes: AttributeContainer( [.font: UIFont.label_sb_14] )
            )
            $0.configuration = configuration
            $0.tintColor = .static_white
            $0.backgroundColor = .bg_cta_secondary
            $0.layer.borderWidth = 1
            $0.layer.borderColor = UIColor.mint300.cgColor
            $0.layer.cornerRadius = .r12
            $0.configurationUpdateHandler = { button in
                UIView.performWithoutAnimation {
                    button.configuration = configuration
                }
            }
            $0.addTarget(self, action: #selector(addRouteButtonDidTap), for: .touchUpInside)
        }
    }
    
    override func setUI() {
        addSubviews(myRouteLabel,
                    countRouteLabel,
                    toggleButton,
                    routeStackView,
                    addRouteButton)
    }
    
    override func setLayout() {
        myRouteLabel.snp.makeConstraints {
            $0.top.leading.equalToSuperview()
            $0.width.equalTo(71)
            $0.height.equalTo(25)
        }
        
        countRouteLabel.snp.makeConstraints {
            $0.centerY.equalTo(myRouteLabel.snp.centerY)
            $0.trailing.equalToSuperview()
            $0.width.equalTo(47)
            $0.height.equalTo(19)
        }
        
        toggleButton.snp.makeConstraints {
            $0.centerY.equalTo(myRouteLabel.snp.centerY)
            $0.trailing.equalToSuperview()
            $0.size.equalTo(24)
        }
        
        routeStackView.snp.makeConstraints {
            $0.top.equalTo(myRouteLabel.snp.bottom).offset(24)
            $0.horizontalEdges.equalToSuperview()
        }
        
        addRouteButton.snp.makeConstraints {
            $0.top.equalTo(routeStackView.snp.bottom).offset(24)
            $0.horizontalEdges.equalToSuperview()
            $0.height.equalTo(48)
            $0.bottom.equalToSuperview()
        }
    }
    
    // MARK: - Public Methods
    
    func configure(mode: RouteViewMode, routePoint: RoutePointModel) {
        self.mode = mode
        self.routePoint = routePoint
        isExpanded = false
        
        updateView()
    }
    
    // MARK: - Private Methods
    
    private func updateView() {
        configureHeader(pointCount: routePoint.points.count)
        configureRoutes(displayedPoints)
    }
    
    private static func defaultRoutePoint() -> RoutePointModel {
        RoutePointDummyData.routePoints
    }
    
    private func configureHeader(pointCount: Int) {
        switch mode {
        case .read:
            countRouteLabel.isHidden = true
            toggleButton.isHidden = !(pointCount > 3)
            UIView.performWithoutAnimation {
                let image: UIImage = isExpanded ? .icArrowUpWhite : .icArrowDownWhite
                toggleButton.setImage(
                    image,
                    for: .normal
                )
                toggleButton.setImage(image, for: .highlighted)
                toggleButton.layoutIfNeeded()
            }
            addRouteButton.isHidden = true
            
        case .write:
            countRouteLabel.text = "(\(pointCount)/\(maxPointCount))"
            countRouteLabel.isHidden = false
            toggleButton.isHidden = true
            addRouteButton.isHidden = pointCount >= maxPointCount
            addRouteButton.isEnabled = pointCount < maxPointCount
            addRouteButton.alpha = 1
        }
    }
    
    private func configureRoutes(_ points: [String]) {
        routeStackView.arrangedSubviews.forEach {
            routeStackView.removeArrangedSubview($0)
            $0.removeFromSuperview()
        }
        
        points.enumerated().forEach { index, point in
            let row = MyRouteRow()
            row.configure(
                number: index + 1,
                title: point,
                isLast: index == points.count - 1,
                showsRemoveButton: showsRemoveButton
            )
            row.onTitleChange = { [weak self] point in
                self?.updateRoutePoint(point, at: index)
            }
            row.onRemoveTap = { [weak self] in
                self?.removeRoutePoint(at: index)
            }
            routeStackView.addArrangedSubview(row)
        }
    }
    
    private var showsRemoveButton: Bool {
        if case .write = mode {
            return true
        }
        return false
    }
    
    @objc
    private func toggleButtonDidTap() {
        guard case .read = mode,
              routePoint.points.count > collapsedPointCount else { return }
        
        isExpanded.toggle()
        UIView.performWithoutAnimation {
            updateView()
            layoutIfNeeded()
        }
    }
    
    @objc
    private func addRouteButtonDidTap() {
        UIView.performWithoutAnimation {
            addRoutePoint()
            layoutIfNeeded()
        }
    }
    
    private var displayedPoints: [String] {
        guard case .read = mode,
              !isExpanded,
              routePoint.points.count > collapsedPointCount else {
            return routePoint.points
        }
        
        return Array(routePoint.points.prefix(collapsedPointCount))
    }
    
    private func addRoutePoint() {
        guard routePoint.points.count < maxPointCount else { return }
        
        routePoint = .init(points: routePoint.points + [""])
        updateView()
    }
    
    private func removeRoutePoint(at index: Int) {
        guard routePoint.points.indices.contains(index) else { return }
        
        var points = routePoint.points
        points.remove(at: index)
        routePoint = .init(points: points)
        updateView()
    }
    
    private func updateRoutePoint(_ point: String, at index: Int) {
        guard routePoint.points.indices.contains(index) else { return }
        
        var points = routePoint.points
        points[index] = point
        routePoint = .init(points: points)
    }
}
