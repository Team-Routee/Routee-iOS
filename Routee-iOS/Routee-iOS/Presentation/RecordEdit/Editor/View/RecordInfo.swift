//
//  DataInfo.swift
//  Routee-iOS
//
//  Created by 김세령 on 7/9/26.
//

import UIKit

import SnapKit
import Then

final class RecordInfo: BaseUIView {
    
    // MARK: - UI Properties
    
    private let dataInfoStackView = UIStackView()
    private let distanceStackView = UIStackView()
    private let distanceLabel = UILabel()
    private let distanceDataLabel = ItalicPaddingLabel()
    private let timeStackView = UIStackView()
    private let timeLabel = UILabel()
    private let timeDataLabel = ItalicPaddingLabel()
    private let altitudeStackView = UIStackView()
    private let altitudeLabel = UILabel()
    private let altitudeDataLabel = ItalicPaddingLabel()

    // MARK: - UI Setting
    
    override func setStyle() {
        dataInfoStackView.do {
            $0.axis = .vertical
            $0.spacing = 10
            $0.alignment = .leading
        }
        
        [distanceStackView, timeStackView, altitudeStackView].forEach {
            $0.axis = .vertical
            $0.spacing = 0
            $0.alignment = .leading
        }
        
        [distanceDataLabel, timeDataLabel, altitudeDataLabel].forEach {
            $0.font = .display_26
            $0.textColor = .recapMint
            $0.setContentCompressionResistancePriority(.required, for: .horizontal)
            $0.setContentHuggingPriority(.required, for: .horizontal)
        }
        
        distanceLabel.do {
            $0.font = .label_sb_12
            $0.textColor = .recapMint
            $0.text = "거리"
        }
        
        distanceDataLabel.do {
            $0.font = .display_26
            $0.textColor = .recapMint
            $0.text = "15.50km"
        }
        
        timeLabel.do {
            $0.font = .label_sb_12
            $0.textColor = .recapMint
            $0.text = "시간"
        }
        
        timeDataLabel.do {
            $0.font = .display_26
            $0.textColor = .recapMint
            $0.text = "3h 20m"
        }
        
        altitudeLabel.do {
            $0.font = .label_sb_12
            $0.textColor = .recapMint
            $0.text = "최고 고도"
        }
        
        altitudeDataLabel.do {
            $0.font = .display_26
            $0.textColor = .recapMint
            $0.text = "2132m"
        }
    }
    
    override func setUI() {
        addSubview(dataInfoStackView)
        
        dataInfoStackView.addArrangedSubviews(distanceStackView, timeStackView, altitudeStackView)
        
        distanceStackView.addArrangedSubviews(distanceLabel, distanceDataLabel)
        
        timeStackView.addArrangedSubviews(timeLabel, timeDataLabel)
        
        altitudeStackView.addArrangedSubviews(altitudeLabel, altitudeDataLabel)
    }
    
    override func setLayout() {
        dataInfoStackView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
        
        [distanceLabel, timeLabel, altitudeLabel].forEach {
            $0.snp.makeConstraints {
                $0.height.equalTo(17)
            }
        }
        
        [distanceDataLabel, timeDataLabel, altitudeDataLabel].forEach {
            $0.snp.makeConstraints {
                $0.height.equalTo(31)
            }
        }
        
    }
    
    // MARK: - Public Methods

    func configure(distance: Int, durationSec: Int, maxElevation: Int) {
        let distanceInKm = Double(distance) / 1000.0
        distanceDataLabel.text = String(format: "%.2fkm", distanceInKm)
        timeDataLabel.text = "\(durationSec / 3600)h \((durationSec % 3600) / 60)m"
        altitudeDataLabel.text = "\(maxElevation)m"
    }
    
    func updateColor(_ color: UIColor) {
        [
            distanceLabel,
            distanceDataLabel,
            timeLabel,
            timeDataLabel,
            altitudeLabel,
            altitudeDataLabel
        ].forEach {
            $0.textColor = color
        }
    }
}
