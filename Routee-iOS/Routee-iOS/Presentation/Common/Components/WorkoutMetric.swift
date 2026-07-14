//
//  WorkoutMetric.swift
//  Routee-iOS
//
//  Created by LEESANGYUP on 7/10/26.
//

import UIKit

import SnapKit
import Then

final class WorkoutMetric: BaseUIView {
    private let measureStackView = UIStackView()
    private let distanceStackView = UIStackView()
    private let distanceLabel = UILabel()
    private let distanceDataLabel = UILabel()
    
    private let timeStackView = UIStackView()
    private let timeLabel = UILabel()
    private let timeDataLabel = UILabel()
    
    private let highestAltitudeStackView = UIStackView()
    private let highestAltitudeLabel = UILabel()
    private let highestAltitudeDataLabel = UILabel()
    
    init(
        distance: String,
        time: String,
        altitude: String
    ) {
        self.distanceDataLabel.text = distance
        self.timeDataLabel.text = time
        self.highestAltitudeDataLabel.text = altitude
        
        super.init(frame: .zero)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func updateDistance(_ distance: String) {
        distanceDataLabel.text = distance
    }
    
    override func setUI() {
        distanceStackView.addArrangedSubviews(distanceLabel, distanceDataLabel)
        
        timeStackView.addArrangedSubviews(timeLabel, timeDataLabel)
        
        highestAltitudeStackView.addArrangedSubviews(highestAltitudeLabel, highestAltitudeDataLabel)
        
        measureStackView.addArrangedSubviews(distanceStackView, timeStackView, highestAltitudeStackView)
        
        addSubview(measureStackView)
    }
    
    override func setStyle() {
        measureStackView.do {
            $0.axis = .horizontal
            $0.alignment = .fill
            $0.distribution = .fillEqually
            $0.spacing = 8
            $0.backgroundColor = .black60
            $0.layer.cornerRadius = 12
            $0.clipsToBounds = true
            $0.isLayoutMarginsRelativeArrangement = true
            $0.layoutMargins = UIEdgeInsets(top: 20, left: 20, bottom: 18, right: 20)
        }
        
        [distanceStackView, timeStackView, highestAltitudeStackView].forEach {
            $0.axis = .vertical
            $0.alignment = .fill
            $0.spacing = 0
        }
        
        [distanceDataLabel, timeDataLabel, highestAltitudeDataLabel].forEach {
            $0.font = .display_30
            $0.textColor = .mint300
            $0.textAlignment = .center
        }
        
        [distanceLabel, timeLabel, highestAltitudeLabel].forEach {
            $0.font = .label_sb_12
            $0.textColor = .mint_300
            $0.textAlignment = .center
            $0.adjustsFontSizeToFitWidth = true
        }
        
        distanceLabel.do {
            $0.text = "거리(km)"
        }
        
        timeLabel.do {
            $0.text = "시간"
        }
        
        highestAltitudeLabel.do {
            $0.text = "최고 고도(m)"
        }
    }
    
    override func setLayout() {
        measureStackView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
    }
}
