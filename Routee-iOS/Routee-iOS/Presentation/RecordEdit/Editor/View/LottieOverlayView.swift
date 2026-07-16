//
//  LottieOverlayView.swift
//  Routee-iOS
//
//  Created by 김세령 on 7/13/26.
//

import UIKit

import Lottie
import SnapKit
import Then

final class LottieOverlayView: BaseUIView {

    // MARK: - UI Properties

    private let backgroundGradientView = RouteeEllipseBackground()
    private lazy var lottieAnimationView = LottieAnimationView(asset: "check")

    // MARK: - UI Setting

    override func setStyle() {
        isHidden = true

        lottieAnimationView.do {
            $0.alpha = 1
            $0.loopMode = .repeat(1)
            $0.contentMode = .scaleAspectFit
        }
    }

    override func setUI() {
        addSubviews(backgroundGradientView, lottieAnimationView)
    }

    override func setLayout() {
        backgroundGradientView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }

        lottieAnimationView.snp.makeConstraints {
            $0.centerY.equalToSuperview()
            $0.centerX.equalToSuperview().offset(5)
            $0.size.equalTo(240)
        }
    }

    // MARK: - Public Methods

    func play(completion: @escaping () -> Void) {
        superview?.bringSubviewToFront(self)
        isHidden = false
        lottieAnimationView.currentProgress = 0

        lottieAnimationView.play { [weak self] _ in
            self?.isHidden = true
            completion()
        }
    }
}
