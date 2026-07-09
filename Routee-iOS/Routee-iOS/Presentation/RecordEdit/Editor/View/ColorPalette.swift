//
//  ColorPaletteView.swift
//  Routee-iOS
//
//  Created by 김세령 on 7/8/26.
//

import UIKit

import SnapKit
import Then

final class ColorPalette: BaseUIView {

    // MARK: - Properties

    private let colors: [UIColor] = [
        .recapOrange,
        .recapLime,
        .recapGreen,
        .recapMint,
        .recapPurple,
        .recapPink,
        .recapWhite,
        .recapNavy
    ]

    private var colorButtons: [ColorCircleButton] = []
    var onColorSelected: ((UIColor) -> Void)?

    // MARK: - UI Properties

    private let backgroundView = UIView()
    private let colorStackView = UIStackView()

    // MARK: - Initializer

    override init(frame: CGRect) {
        super.init(frame: frame)

        makeButtons()
    }

    required init?(coder: NSCoder) {
        fatalError()
    }

    // MARK: - UI Setting

    override func setStyle() {
        backgroundView.backgroundColor = .dimPrimary

        colorStackView.do {
            $0.axis = .horizontal
            $0.distribution = .equalSpacing
            $0.alignment = .center
            $0.spacing = 6
        }
    }

    override func setUI() {
        addSubviews(backgroundView, colorStackView)
    }

    override func setLayout() {
        backgroundView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }

        colorStackView.snp.makeConstraints {
            $0.center.equalToSuperview()
            $0.height.equalTo(48)
        }
    }

    // MARK: - Private Methods

    private func makeButtons() {
        for color in colors {
            let button = ColorCircleButton(color: color)

            setAction(to: button)
            colorButtons.append(button)
            colorStackView.addArrangedSubview(button)
        }

        colorButtons.first?.setSelected(true)
    }

    private func setAction(to button: ColorCircleButton) {
        button.addTarget(
            self,
            action: #selector(colorButtonTapped(_:)),
            for: .touchUpInside
        )
    }

    // MARK: - Actions

    @objc
    private func colorButtonTapped(_ sender: ColorCircleButton) {
        colorButtons.forEach {
            $0.setSelected(false)
        }

        sender.setSelected(true)
        onColorSelected?(sender.color)
    }
}
