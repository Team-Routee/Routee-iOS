//
//  ColorCircleButton.swift
//  Routee-iOS
//
//  Created by 김세령 on 7/8/26.
//

import SnapKit
import Then
import UIKit

final class ColorCircleButton: UIButton {

    // MARK: - Properties

    let color: UIColor

    // MARK: - UI Properties

    private let colorView = UIView()
    private let selectedBorderView = UIView()

    // MARK: - Initializer

    init(color: UIColor) {
        self.color = color
        super.init(frame: .zero)

        colorView.backgroundColor = color

        setStyle()
        setUI()
        setLayout()
    }

    required init?(coder: NSCoder) {
        fatalError()
    }

    // MARK: - UI Setting

    private func setStyle() {
        colorView.do {
            $0.isUserInteractionEnabled = false
            $0.layer.cornerRadius = 14
            $0.layer.borderWidth = 1
            $0.layer.borderColor = UIColor.static_white.cgColor
        }

        selectedBorderView.do {
            $0.isHidden = true
            $0.isUserInteractionEnabled = false
            $0.backgroundColor = .clear
            $0.layer.cornerRadius = 18
            $0.layer.borderWidth = 2
            $0.layer.borderColor = UIColor.static_white.cgColor
        }
    }

    private func setUI() {
        addSubviews(colorView, selectedBorderView)
    }

    private func setLayout() {
        colorView.snp.makeConstraints {
            $0.edges.equalToSuperview().inset(4)
        }

        selectedBorderView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
    }

    // MARK: - Public Methods

    override func point(inside point: CGPoint, with event: UIEvent?) -> Bool {
        bounds.insetBy(dx: -6, dy: -6).contains(point)
    }

    func setSelected(_ selected: Bool) {
        selectedBorderView.isHidden = !selected
    }
}
