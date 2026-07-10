//
//  ImageCropView.swift
//  Routee-iOS
//
//  Created by 김세령 on 7/10/26.
//

import UIKit

import SnapKit

final class ImageCropView: BaseUIView {
    
    // MARK: - UI Properties
    
    let topNavigationBar = TopNavigationBar(rightTitle: "확인")
    
    // MARK: - UI Setting
    
    override func setStyle() {
        backgroundColor = .bgPrimary
    }
    
    override func setUI() {
        addSubview(topNavigationBar)
    }
    
    override func setLayout() {
        topNavigationBar.snp.makeConstraints {
            $0.top.equalTo(safeAreaLayoutGuide)
            $0.horizontalEdges.equalToSuperview()
        }
    }
    
    // MARK: - Public Methods
    
    func setCropContentView(_ cropContentView: UIView) {
        addSubview(cropContentView)
        
        cropContentView.snp.makeConstraints {
            $0.top.equalTo(topNavigationBar.snp.bottom)
            $0.horizontalEdges.bottom.equalToSuperview()
        }
    }
}
