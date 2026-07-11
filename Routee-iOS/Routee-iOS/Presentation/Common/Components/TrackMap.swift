//
//  TrackMap.swift
//  Routee-iOS
//
//  Created by LEESANGYUP on 7/10/26.
//

import UIKit

import SnapKit
import Then

final class TrackMap: BaseUIView {

    private let backgroundImage: UIImage?
    private let trackPoints: [TrackPoint]
    
    private let backgroundImageView = UIImageView()
    private let routeLayer = CAShapeLayer()

    init(
        backgroundImage: UIImage?,
        trackPoints: [TrackPoint]
    ) {
        self.backgroundImage = backgroundImage
        self.trackPoints = trackPoints

        super.init(frame: .zero)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func layoutSubviews() {
        super.layoutSubviews()

        drawRoute()
    }

    override func setStyle() {
        backgroundImageView.do {
            $0.image = backgroundImage
            $0.contentMode = .scaleAspectFill
            $0.clipsToBounds = true
            $0.layer.cornerRadius = 12
        }

        routeLayer.do {
            $0.fillColor = UIColor.clear.cgColor
            $0.strokeColor = UIColor.mint_300.cgColor
            $0.lineWidth = 3
        }
    }

    override func setUI() {
        addSubview(backgroundImageView)

        backgroundImageView.layer.addSublayer(routeLayer)
    }

    override func setLayout() {
        backgroundImageView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
    }

    private func drawRoute() {
        let canvasSize = backgroundImageView.bounds.size

        guard canvasSize.width > 0,
              canvasSize.height > 0
        else {
            return
        }

        let canvasPoints = trackPoints.toCanvasPoints(in: canvasSize)

        guard let firstPoint = canvasPoints.first else {
            return
        }

        let path = UIBezierPath()
        path.move(to: firstPoint)

        for point in canvasPoints.dropFirst() {
            path.addLine(to: point)
        }

        routeLayer.frame = backgroundImageView.bounds
        routeLayer.path = path.cgPath
    }
}
