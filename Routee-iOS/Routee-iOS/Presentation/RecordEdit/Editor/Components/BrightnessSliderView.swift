//
//  BrightnessSliderView.swift
//  Routee-iOS
//
//  Created by 김세령 on 8/25/26.
//

import UIKit

import SnapKit
import Then

final class BrightnessSliderView: BaseUIView {

    // MARK: - Properties

    var onValueChanged: ((CGFloat) -> Void)?

    private enum Layout {
        static let tickSpacing: CGFloat = 8
        static let tickMarkWidthMultiplier: CGFloat = 2
        static let tickMarkHeight: CGFloat = 12
        static let indicatorWidth: CGFloat = 2
        static let indicatorHeight: CGFloat = 26
    }
    private var tickMarkCenterXConstraint: Constraint?

    // MARK: - UI Properties

    private let backgroundView = UIView()
    private let tickMarkView = BrightnessTickMarkView(tickSpacing: Layout.tickSpacing)
    private let currentValueIndicatorView = UIView()
    private let slider = BrightnessTrackingSlider()

    // MARK: - UI Setting

    override func setStyle() {
        clipsToBounds = true

        backgroundView.do {
            $0.backgroundColor = .dimPrimary
        }

        currentValueIndicatorView.do {
            $0.backgroundColor = .staticWhite
            $0.layer.cornerRadius = Layout.indicatorWidth / 2
            $0.clipsToBounds = true
        }

        slider.do {
            $0.minimumValue = 0
            $0.maximumValue = 1
            $0.value = 0.5
            $0.minimumTrackTintColor = .clear
            $0.maximumTrackTintColor = .clear
            $0.setThumbImage(Self.transparentThumbImage(), for: .normal)
            $0.setThumbImage(Self.transparentThumbImage(), for: .highlighted)
        }
    }

    override func setUI() {
        addSubviews(
            backgroundView,
            tickMarkView,
            currentValueIndicatorView,
            slider
        )

        setAction()
    }

    override func setLayout() {
        backgroundView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }

        tickMarkView.snp.makeConstraints {
            tickMarkCenterXConstraint = $0.centerX.equalToSuperview().constraint
            $0.top.equalToSuperview().offset(13)
            $0.width.equalToSuperview().multipliedBy(Layout.tickMarkWidthMultiplier)
            $0.height.equalTo(Layout.tickMarkHeight)
        }

        currentValueIndicatorView.snp.makeConstraints {
            $0.centerX.equalToSuperview()
            $0.top.equalToSuperview()
            $0.width.equalTo(Layout.indicatorWidth)
            $0.height.equalTo(Layout.indicatorHeight)
        }

        slider.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
    }

    override func layoutSubviews() {
        super.layoutSubviews()

        updateTickMarkPosition()
    }

    // MARK: - Public Methods

    func setValue(_ value: CGFloat) {
        slider.value = Float(min(max(value, 0), 1))
        updateTickMarkPosition()
    }

    // MARK: - Private Methods

    private func setAction() {
        slider.addTarget(
            self,
            action: #selector(sliderValueChanged(_:)),
            for: .valueChanged
        )
    }

    private func updateTickMarkPosition() {
        let sliderValue = CGFloat(slider.value)
        let tickMarkCenterOffset = (0.5 - sliderValue) * bounds.width

        tickMarkCenterXConstraint?.update(offset: tickMarkCenterOffset)
    }

    private static func transparentThumbImage() -> UIImage {
        UIGraphicsImageRenderer(size: CGSize(width: 1, height: 1)).image { _ in }
    }

    // MARK: - Actions

    @objc
    private func sliderValueChanged(_ sender: UISlider) {
        updateTickMarkPosition()
        onValueChanged?(CGFloat(sender.value))
    }
}

private final class BrightnessTrackingSlider: UISlider {

    override func beginTracking(_ touch: UITouch, with event: UIEvent?) -> Bool {
        updateValue(with: touch)
        return true
    }

    override func continueTracking(_ touch: UITouch, with event: UIEvent?) -> Bool {
        updateValue(with: touch)
        return true
    }

    private func updateValue(with touch: UITouch) {
        guard bounds.width > 0 else { return }

        let touchRatio = touch.location(in: self).x / bounds.width
        let clampedRatio = min(max(touchRatio, 0), 1)

        value = minimumValue + Float(clampedRatio) * (maximumValue - minimumValue)
        sendActions(for: .valueChanged)
    }
}

private final class BrightnessTickMarkView: UIView {

    // MARK: - Properties

    private enum Layout {
        static let lineWidth: CGFloat = 2
    }
    private let tickSpacing: CGFloat

    // MARK: - Initializer

    init(tickSpacing: CGFloat) {
        self.tickSpacing = tickSpacing
        super.init(frame: .zero)

        backgroundColor = .clear
        isUserInteractionEnabled = false
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Drawing

    override func draw(_ rect: CGRect) {
        guard tickSpacing > 0 else { return }

        let context = UIGraphicsGetCurrentContext()
        let tickCount = Int(ceil(bounds.width / tickSpacing))

        for index in 0...tickCount {
            let tickPositionX = CGFloat(index) * tickSpacing
            let isAccentTick = index.isMultiple(of: 10)

            context?.setStrokeColor(
                (isAccentTick ? UIColor.staticWhite : UIColor.white30).cgColor
            )
            let halfLineWidth = Layout.lineWidth / 2

            context?.setLineWidth(Layout.lineWidth)
            context?.setLineCap(.round)
            context?.move(to: CGPoint(x: tickPositionX, y: bounds.minY + halfLineWidth))
            context?.addLine(to: CGPoint(x: tickPositionX, y: bounds.maxY - halfLineWidth))
            context?.strokePath()
        }
    }
}
