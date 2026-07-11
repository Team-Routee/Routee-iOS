//
//  RouteSticker.swift
//  Routee-iOS
//
//  Created by 김세령 on 7/11/26.
//

import UIKit

import SnapKit
import Then

final class RouteSticker: BaseUIView {
    
    // MARK: - Properties
    
    private var routeTitles = RouteStickerDummyData.routeTitles
    
    // MARK: - UI Properties
    
    private let routeIconImageView = UIImageView()
    private let routeTitleStackView = UIStackView()
    
    // MARK: - UI Setting
    
    override func setStyle() {
        routeIconImageView.do {
            $0.image = UIImage(named: "ic_location_info_sm_mint_no_spacing")
        }
        
        routeTitleStackView.do {
            $0.axis = .vertical
            $0.spacing = 6
            $0.alignment = .leading
            $0.tintColor = .recapMint
        }
    }
    
    override func setUI() {
        addSubviews(routeIconImageView, routeTitleStackView)
        setRouteTitles(routeTitles)
    }
    
    override func setLayout() {
        routeIconImageView.snp.makeConstraints {
            $0.top.leading.equalToSuperview()
            $0.height.equalTo(14)
        }
        
        routeTitleStackView.snp.makeConstraints {
            $0.top.equalTo(routeIconImageView.snp.bottom).offset(6)
            $0.leading.trailing.bottom.equalToSuperview()
        }
    }
    
    // MARK: - Public Methods
    
    func configure(with routeTitles: [String]) {
        self.routeTitles = routeTitles
        setRouteTitles(routeTitles)
    }
    
    // MARK: - Private Methods
    
    private func setRouteTitles(_ routeTitles: [String]) {
        routeTitleStackView.arrangedSubviews.forEach {
            routeTitleStackView.removeArrangedSubview($0)
            $0.removeFromSuperview()
        }
        
        routeTitles.forEach {
            routeTitleStackView.addArrangedSubview(makeRouteTitleLabel(text: $0))
        }
    }
    
    private func makeRouteTitleLabel(text: String) -> UILabel {
        UILabel().then {
            $0.text = text
            $0.font = .label_m_12
            $0.textColor = .staticWhite
            $0.numberOfLines = 1
        }
    }
}
