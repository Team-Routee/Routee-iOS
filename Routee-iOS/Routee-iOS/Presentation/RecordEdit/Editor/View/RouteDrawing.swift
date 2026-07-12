//
//  RouteDrawingView.swift
//  Routee-iOS
//
//  Created by 김세령 on 7/12/26.
//

import UIKit

final class RouteDrawingView: UIView {
    
    // MARK: - Properties
    
    private var points: [CGPoint] = []
    private var baseCanvasSize: CGSize = .zero
    private var contentSize: CGSize = .zero
    private var routeColor: UIColor = .recapMint
    
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
    
    func configure(points: [CGPoint], baseCanvasSize: CGSize) {
        self.points = points
        self.baseCanvasSize = baseCanvasSize
        self.contentSize = baseCanvasSize
        invalidateIntrinsicContentSize()
        setNeedsDisplay()
    }
    
    func configureSticker(points: [CGPoint]) {
        guard let routeRect = routeRect(from: points) else { return }
        
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
        self.baseCanvasSize = routeSize
        self.contentSize = routeSize
        invalidateIntrinsicContentSize()
        setNeedsDisplay()
    }
    
    func updateColor(_ color: UIColor) {
        routeColor = color
        setNeedsDisplay()
    }
    
    // MARK: - Private Methods
    
    private func scaledPoint(_ point: CGPoint) -> CGPoint {
        guard baseCanvasSize.width > 0,
              baseCanvasSize.height > 0
        else {
            return point
        }
        
        return CGPoint(
            x: point.x * bounds.width / baseCanvasSize.width,
            y: point.y * bounds.height / baseCanvasSize.height
        )
    }
    
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
        path.move(to: scaledPoint(points[0]))
        
        points.dropFirst().forEach {
            path.addLine(to: scaledPoint($0))
        }
        
        routeColor.setStroke()
        path.lineWidth = 3
        path.lineCapStyle = .round
        path.lineJoinStyle = .round
        path.stroke()
    }
    
    override func draw(_ rect: CGRect) {
        drawRoute()
    }
}
