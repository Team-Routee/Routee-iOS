//
//  WorkoutPauseView.swift
//  Routee-iOS
//
//  Created by LEESANGYUP on 7/10/26.
//

import UIKit

import SnapKit
import Then

final class WorkoutPauseView: BaseUIView {
    
    // MARK: - UI Properties
    
    private let backgroundGradientLayer = CAGradientLayer()
    private let recordInfoStackView = UIStackView()
    private let distanceStackView = UIStackView()
    private let distanceLabel = UILabel()
    private let distanceDataLabel = UILabel()
    private let timeStackView = UIStackView()
    private let timeLabel = UILabel()
    private let timeDataLabel = UILabel()
    private let altitudeStackView = UIStackView()
    private let altitudeLabel = UILabel()
    private let altitudeDataLabel = UILabel()
    private let buttonStackView = UIStackView()
    let restartButton = UIButton()
    let finishButton = UIButton()
    
    // MARK: - UI Setting
    
    override func setUI() {
        addSubviews(recordInfoStackView, buttonStackView)
        
        recordInfoStackView.addArrangedSubviews(distanceStackView, timeStackView, altitudeStackView)
        
        distanceStackView.addArrangedSubviews(distanceLabel, distanceDataLabel)
        
        timeStackView.addArrangedSubviews(timeLabel, timeDataLabel)
        
        altitudeStackView.addArrangedSubviews(altitudeLabel, altitudeDataLabel)
        
        buttonStackView.addArrangedSubviews(restartButton, finishButton)
    }
    
    override func setStyle() {
        backgroundColor = .mint500
        
        backgroundGradientLayer.do {
            $0.type = .radial
            $0.colors = [
                UIColor.lime300.cgColor,
                UIColor.lime300.withAlphaComponent(0).cgColor
            ]
            $0.locations = [0.0, 1.0]
            $0.startPoint = CGPoint(x: 0.5, y: 0.5)
            $0.endPoint = CGPoint(x: 1.0, y: 1.0)
        }
        
        layer.insertSublayer(backgroundGradientLayer, at: 0)
        
        recordInfoStackView.do {
            $0.axis = .vertical
            $0.spacing = 16
            $0.alignment = .center
        }
        
        [distanceStackView, timeStackView, altitudeStackView].forEach {
            $0.axis = .vertical
            $0.spacing = 0
            $0.alignment = .center
        }
        
        [distanceLabel, timeLabel, altitudeLabel].forEach {
            $0.font = .title_sb_18
            $0.textColor = .black60
        }
        
        [distanceDataLabel, timeDataLabel, altitudeDataLabel].forEach {
            $0.font = .display_52
            $0.textColor = .staticBlack
            $0.textAlignment = .center
        }
        
        distanceLabel.do {
            $0.text = "거리"
        }
        
        distanceDataLabel.do {
            $0.text = "15.5km"
        }
        
        timeLabel.do {
            $0.text = "시간"
        }
        
        timeDataLabel.do {
            $0.text = "03h 03m"
        }
        
        altitudeLabel.do {
            $0.text = "고도"
        }
        
        altitudeDataLabel.do {
            $0.text = "2132m"
        }
        
        restartButton.do {
            $0.setTitle("다시 시작", for: .normal)
            $0.setImage(.icRestart, for: .normal)
            $0.titleLabel?.font = .label_sb_16
            $0.setTitleColor(.bgPrimary, for: .normal)
            $0.backgroundColor = .staticWhite
            $0.layer.cornerRadius = 30
            $0.clipsToBounds = true
        }
        
        finishButton.do {
            $0.setTitle("종료", for: .normal)
            $0.titleLabel?.font = .label_sb_16
            $0.setTitleColor(.lime400, for: .normal)
            $0.backgroundColor = .staticBlack
            $0.layer.cornerRadius = 30
            $0.clipsToBounds = true
        }
        
        buttonStackView.do {
            $0.spacing = 12
            $0.alignment = .center
            $0.axis = .horizontal
        }
    }
    
    override func setLayout() {
        recordInfoStackView.snp.makeConstraints {
            $0.centerX.equalToSuperview()
            $0.bottom.equalTo(restartButton.snp.top).offset(-190)
            $0.horizontalEdges.equalToSuperview()
        }
        
        [distanceStackView, timeStackView, altitudeStackView].forEach {
            $0.snp.makeConstraints {
                $0.horizontalEdges.equalToSuperview()
            }
            
            [distanceDataLabel, timeDataLabel, altitudeDataLabel].forEach {
                $0.snp.makeConstraints {
                    $0.horizontalEdges.equalToSuperview()
                }
            }
            
            restartButton.snp.makeConstraints {
                $0.width.equalTo(139)
                $0.height.equalTo(60)
            }
            
            finishButton.snp.makeConstraints {
                $0.width.equalTo(60)
                $0.height.equalTo(60)
            }
            
            buttonStackView.snp.makeConstraints {
                $0.bottom.equalTo(safeAreaLayoutGuide).inset(31)
                $0.centerX.equalToSuperview()
            }
        }
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        backgroundGradientLayer.frame = bounds
    }
}
