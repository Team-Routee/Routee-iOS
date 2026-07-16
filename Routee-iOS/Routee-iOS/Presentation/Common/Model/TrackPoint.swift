//
//  TrackPoint.swift
//  Routee-iOS
//
//  Created by LEESANGYUP on 7/11/26.
//

import CoreGraphics

struct TrackPoint {
    let latitude: Double
    let longitude: Double
}

extension Array where Element == TrackPoint {
    func toCanvasPoints(in canvasSize: CGSize, padding: CGFloat = 60) -> [CGPoint] {
        guard count >= 2 else {
            return []
        }

        let latitudes = map(\.latitude)
        let longitudes = map(\.longitude)

        guard let minLatitude = latitudes.min(),
              let maxLatitude = latitudes.max(),
              let minLongitude = longitudes.min(),
              let maxLongitude = longitudes.max()
        else {
            return []
        }

        let latitudeRange = maxLatitude - minLatitude
        let longitudeRange = maxLongitude - minLongitude

        guard latitudeRange > 0, longitudeRange > 0
        else {
            return []
        }

        let drawableWidth = canvasSize.width - padding * 2
        let drawableHeight = canvasSize.height - padding * 2

        let scaleX = drawableWidth / CGFloat(longitudeRange)
        let scaleY = drawableHeight / CGFloat(latitudeRange)

        let scale = Swift.min(scaleX, scaleY)

        let routeWidth = CGFloat(longitudeRange) * scale
        let routeHeight = CGFloat(latitudeRange) * scale

        let offsetX = (canvasSize.width - routeWidth) / 2
        let offsetY = (canvasSize.height - routeHeight) / 2

        return map { point in
            let xPoint = CGFloat(point.longitude - minLongitude) * scale + offsetX

            let yPoint = CGFloat(maxLatitude - point.latitude) * scale + offsetY

            return CGPoint(x: xPoint, y: yPoint)
        }
    }
}

extension TrackPoint {
    static func dummyTrackPoints() -> [TrackPoint] {
        [
            TrackPoint(latitude: 37.5665, longitude: 126.9780),
            TrackPoint(latitude: 37.5670, longitude: 126.9785),
            TrackPoint(latitude: 37.5680, longitude: 126.9790),
            TrackPoint(latitude: 37.5685, longitude: 126.9800),
            TrackPoint(latitude: 37.5695, longitude: 126.9810),
            TrackPoint(latitude: 37.5700, longitude: 126.9825),
            TrackPoint(latitude: 37.5710, longitude: 126.9830),
            TrackPoint(latitude: 37.5715, longitude: 126.9845),
            TrackPoint(latitude: 37.5720, longitude: 126.9850),
            TrackPoint(latitude: 37.5730, longitude: 126.9840),
            TrackPoint(latitude: 37.5740, longitude: 126.9835),
            TrackPoint(latitude: 37.5750, longitude: 126.9820),
            TrackPoint(latitude: 37.5755, longitude: 126.9805),
            TrackPoint(latitude: 37.5745, longitude: 126.9790),
            TrackPoint(latitude: 37.5730, longitude: 126.9785)
        ]
    }
}
