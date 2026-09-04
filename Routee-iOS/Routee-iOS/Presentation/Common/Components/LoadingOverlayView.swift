//
//  LoadingOverlayView.swift
//  Routee-iOS
//
//  Created by LEESANGYUP on 9/3/26.
//

import UIKit

import Lottie
import SnapKit
import Then

final class LoadingOverlayView: BaseUIView {

    // MARK: - UI Properties

    private let loadingAnimationView = LottieAnimationView(name: "loading")
    private let messageLabel = UILabel()

    // MARK: - UI Setting

    override func setStyle() {
        backgroundColor = .dim_secondary
        isUserInteractionEnabled = true

        loadingAnimationView.do {
            $0.contentMode = .scaleAspectFit
            $0.loopMode = .loop
        }

        messageLabel.do {
            $0.font = .label_m_16
            $0.textColor = .staticWhite
            $0.textAlignment = .center
            $0.numberOfLines = 0
        }

        accessibilityViewIsModal = true
        accessibilityLabel = "로딩 중"
    }

    override func setUI() {
        addSubviews(loadingAnimationView, messageLabel)
    }

    override func setLayout() {
        loadingAnimationView.snp.makeConstraints {
            $0.centerX.equalToSuperview()
            $0.bottom.equalTo(messageLabel.snp.bottom)
            $0.size.equalTo(276)
        }

        messageLabel.snp.makeConstraints {
            $0.top.equalTo(self.snp.centerY)
            $0.centerY.equalToSuperview().offset(36.5)
            $0.centerX.equalToSuperview()
        }
    }

    func startAnimation(message: String) {
        messageLabel.text = message
        loadingAnimationView.play()
        accessibilityValue = message
    }

    func stopAnimation() {
        loadingAnimationView.stop()
    }
}
