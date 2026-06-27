//
//  SampleView.swift
//  Routee-iOS
//
//  Created by LEESANGYUP on 6/27/26.
//

import UIKit

import SnapKit
import Then

final class SampleView: BaseUIView {
    private let nameLabel = UILabel()
    
    override func setStyle() {
        backgroundColor = .brown
        
        nameLabel.do {
            $0.text = "SampleView"
            $0.textColor = .white
        }
    }
    
    override func setUI() {
        addSubviews(nameLabel)
    }
    
    override func setLayout() {
        nameLabel.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
    }
}
