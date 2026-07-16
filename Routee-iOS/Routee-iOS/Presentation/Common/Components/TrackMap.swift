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

    struct Photo {
        let image: UIImage
        let pointIndex: Int
    }

    private let backgroundImage: UIImage?
    private var trackPoints: [TrackPoint]
    private let photos: [Photo]
    private let markerSize = CGSize(width: 42, height: 42)

    private let backgroundImageView = UIImageView()
    private let routeLayer = CAShapeLayer()
    private var photoMarkerViews: [(imageView: UIImageView, pointIndex: Int)] = []

    init(
        backgroundImage: UIImage?,
        trackPoints: [TrackPoint],
        photos: [Photo] = []
    ) {
        self.backgroundImage = backgroundImage
        self.trackPoints = trackPoints
        self.photos = photos

        super.init(frame: .zero)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func layoutSubviews() {
        super.layoutSubviews()

        let canvasSize = backgroundImageView.bounds.size

        guard canvasSize.width > 0,
              canvasSize.height > 0
        else {
            return
        }

        let canvasPoints = trackPoints.toCanvasPoints(in: canvasSize)
        drawRoute(with: canvasPoints)
        layoutPhotoMarkers(with: canvasPoints)
    }

    func updateTrackPoints(_ trackPoints: [TrackPoint]) {
        self.trackPoints = trackPoints
        setNeedsLayout()
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

        addPhotoMarkerViews()
    }

    override func setLayout() {
        backgroundImageView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
    }

    private func drawRoute(with canvasPoints: [CGPoint]) {
        guard let firstPoint = canvasPoints.first else {
            routeLayer.path = nil
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

    private func addPhotoMarkerViews() {
        photos.forEach { photo in
            let imageView = UIImageView()
            imageView.isHidden = true
            backgroundImageView.addSubview(imageView)
            photoMarkerViews.append((imageView, photo.pointIndex))
            setThumbnail(photo.image, on: imageView)
        }
    }

    private func setThumbnail(_ sourceImage: UIImage, on imageView: UIImageView) {
        let size = markerSize

        Task { [weak imageView] in
            let thumbnail = await Task.detached(priority: .userInitiated) {
                sourceImage
                    .resized(to: size)
                    .thumbnailImage(borderWidth: 3, borderColor: .mint300, cornerRadius: 12)
            }.value

            imageView?.image = thumbnail
        }
    }

    private func layoutPhotoMarkers(with canvasPoints: [CGPoint]) {
        photoMarkerViews.forEach { imageView, pointIndex in
            let index = pointIndex - 1

            guard canvasPoints.indices.contains(index) else {
                imageView.isHidden = true
                return
            }

            imageView.isHidden = false
            imageView.frame = CGRect(
                x: canvasPoints[index].x - markerSize.width / 2,
                y: canvasPoints[index].y - markerSize.height / 2,
                width: markerSize.width,
                height: markerSize.height
            )
        }
    }
}
