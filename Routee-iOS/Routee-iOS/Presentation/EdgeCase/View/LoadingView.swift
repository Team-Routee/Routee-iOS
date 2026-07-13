//
//  LoadingView.swift
//  Routee-iOS
//
//  Created by 초긍정행운의포춘쿠키 on 7/13/26.
//

import UIKit

import Lottie
import SnapKit
import Then

final class LoadingView: BaseUIView {
    
    // MARK: - UI Properties
    
    private let backgroundGradientView = RouteeEllipseBackground()
    private let loadingLabel = UILabel()
    let lottieView = LottieAnimationView(name: "loading")
        
    // MARK: - UI Setting
    
    override func setStyle() {        
        loadingLabel.do {
            $0.text = "정보가 하산 중이에요"
            $0.font = .label_m_16
            $0.textColor = .staticWhite
        }
    }
    
    override func setUI() {
        addSubviews(backgroundGradientView, lottieView, loadingLabel)
    }
    
    override func setLayout() {
        backgroundGradientView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
        
        loadingLabel.snp.makeConstraints {
            $0.top.equalTo(self.snp.centerY)
            $0.centerX.equalToSuperview()
        }
        
        lottieView.snp.makeConstraints {
            $0.centerX.equalToSuperview()
            $0.bottom.equalTo(loadingLabel.snp.bottom).offset(37)
            $0.size.equalTo(276)
        }
    }
}
