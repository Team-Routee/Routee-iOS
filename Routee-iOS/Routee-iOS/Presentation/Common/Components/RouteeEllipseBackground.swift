//
//  RouteeEllipseBackground.swift
//  Routee-iOS
//
//  Created by LEESANGYUP on 7/6/26.
//

import UIKit

import SnapKit

final class RouteeEllipseBackground: UIView {
    private let backgroundEllipseView = UIView()
    private let backgroundGradientLayer = CAGradientLayer()
    private let backgroundEllipseMaskLayer = CAShapeLayer()

    override init(frame: CGRect) {
        super.init(frame: frame)
        configureBaseBackground()
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }

    override func layoutSubviews() {
        super.layoutSubviews()
        backgroundGradientLayer.frame = backgroundEllipseView.bounds
        backgroundEllipseMaskLayer.frame = backgroundEllipseView.bounds
        backgroundEllipseMaskLayer.path = UIBezierPath(ovalIn: backgroundEllipseView.bounds).cgPath
    }

    private func configureBaseBackground() {
        backgroundColor = UIColor(red: 16 / 255, green: 16 / 255, blue: 16 / 255, alpha: 1)
        clipsToBounds = true

        backgroundEllipseView.isUserInteractionEnabled = false
        backgroundEllipseView.backgroundColor = .clear
        backgroundEllipseView.layer.mask = backgroundEllipseMaskLayer

        backgroundGradientLayer.type = .radial
        backgroundGradientLayer.colors = [
            UIColor(red: 176 / 255, green: 245 / 255, blue: 250 / 255, alpha: 0.08).cgColor,
            UIColor(red: 176 / 255, green: 245 / 255, blue: 250 / 255, alpha: 0).cgColor
        ]
        backgroundGradientLayer.locations = [0, 1]
        backgroundGradientLayer.startPoint = CGPoint(x: 0.5, y: 0.5)
        backgroundGradientLayer.endPoint = CGPoint(x: 1, y: 1)

        backgroundEllipseView.layer.addSublayer(backgroundGradientLayer)
        addSubview(backgroundEllipseView)

        backgroundEllipseView.snp.makeConstraints {
            $0.centerX.equalToSuperview()
            $0.top.equalToSuperview().inset(-103)
            $0.width.equalTo(433)
            $0.height.equalTo(568)
        }
    }
}
