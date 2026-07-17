//
//  RouteDrawer.swift
//  Routee-iOS
//
//  Created by 김세령 on 7/12/26.
//

import Kingfisher
import SnapKit
import UIKit

struct RouteTimelineMarker {
    let thumbnailUrl: String
    let point: CGPoint
}

final class RouteDrawer: UIView {

    // MARK: - Properties

    private let routeLineWidth: CGFloat = 3
    private let markerSize: CGFloat = 36
    private var points: [CGPoint] = []
    private var contentSize: CGSize = .zero
    private var routeColor: UIColor = .recapMint
    private var markerImageViews: [UIImageView] = []

    override var intrinsicContentSize: CGSize {
        contentSize == .zero ? super.intrinsicContentSize : contentSize
    }

    // MARK: - Initializer

    override init(frame: CGRect) {
        super.init(frame: frame)

        backgroundColor = .clear
        contentMode = .redraw
        isUserInteractionEnabled = false
    }

    required init?(coder: NSCoder) {
        fatalError()
    }

    // MARK: - Public Methods

    func configureSticker(points: [CGPoint], markers: [RouteTimelineMarker]) -> CGRect? {
        guard let routeRect = contentRect(from: points, markers: markers) else { return nil }

        let routeSize = CGSize(
            width: max(routeRect.width, 1),
            height: max(routeRect.height, 1)
        )

        self.points = points.map {
            CGPoint(
                x: $0.x - routeRect.minX,
                y: $0.y - routeRect.minY
            )
        }
        self.contentSize = routeSize
        configureMarkers(markers, routeRect: routeRect)

        invalidateIntrinsicContentSize()
        setNeedsDisplay()

        return routeRect
    }

    func updateColor(_ color: UIColor) {
        routeColor = color
        markerImageViews.forEach {
            $0.layer.borderColor = color.cgColor
        }
        setNeedsDisplay()
    }

    // MARK: - Private Methods

    private func routeRect(from points: [CGPoint]) -> CGRect? {
        guard let minX = points.map(\.x).min(),
              let maxX = points.map(\.x).max(),
              let minY = points.map(\.y).min(),
              let maxY = points.map(\.y).max()
        else {
            return nil
        }

        return CGRect(
            x: minX,
            y: minY,
            width: maxX - minX,
            height: maxY - minY
        )
    }

    private func drawRoute() {
        guard points.count > 1 else { return }

        let path = UIBezierPath()
        path.move(to: points[0])

        points.dropFirst().forEach {
            path.addLine(to: $0)
        }

        routeColor.setStroke()
        path.lineWidth = routeLineWidth
        path.lineCapStyle = .round
        path.lineJoinStyle = .round
        path.stroke()
    }

    override func draw(_ rect: CGRect) {
        drawRoute()
    }

    private func configureMarkers(
        _ markers: [RouteTimelineMarker],
        routeRect: CGRect
    ) {
        markerImageViews.forEach { $0.removeFromSuperview() }
        markerImageViews.removeAll()

        markers.forEach { marker in
            let imageView = UIImageView()
            imageView.contentMode = .scaleAspectFill
            imageView.clipsToBounds = true
            imageView.layer.cornerRadius = 12
            imageView.layer.borderWidth = 3
            imageView.layer.borderColor = routeColor.cgColor

            if let url = URL(string: marker.thumbnailUrl) {
                imageView.kf.setImage(with: url)
            }

            addSubview(imageView)
            markerImageViews.append(imageView)

            imageView.snp.makeConstraints {
                $0.size.equalTo(markerSize)
                $0.center.equalTo(
                    CGPoint(
                        x: marker.point.x - routeRect.minX,
                        y: marker.point.y - routeRect.minY
                    )
                )
            }
        }
    }

    private func contentRect(
        from points: [CGPoint],
        markers: [RouteTimelineMarker]
    ) -> CGRect? {
        guard var rect = routeRect(from: points) else { return nil }

        let routePadding = routeLineWidth / 2
        rect = rect.insetBy(dx: -routePadding, dy: -routePadding)

        markers.forEach {
            let markerRect = CGRect(
                x: $0.point.x - markerSize / 2,
                y: $0.point.y - markerSize / 2,
                width: markerSize,
                height: markerSize
            )
            rect = rect.union(markerRect)
        }

        return rect
    }
}
