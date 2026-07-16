//
//  ImageCropView.swift
//  Routee-iOS
//
//  Created by 김세령 on 7/10/26.
//

import SnapKit
import UIKit

final class ImageCropView: BaseUIView {
    
    // MARK: - UI Properties
    
    let topNavigationBar = TopNavigationBar(rightTitle: "확인")
    private let cropContentView: UIView
    
    // MARK: - Initializer
    
    init(cropContentView: UIView) {
        self.cropContentView = cropContentView
        super.init(frame: .zero)
    }
    
    required init?(coder: NSCoder) {
        fatalError()
    }
    
    // MARK: - UI Setting
    
    override func setStyle() {
        backgroundColor = .bgPrimary
    }
    
    override func setUI() {
        addSubviews(topNavigationBar, cropContentView)
    }
    
    override func setLayout() {
        topNavigationBar.snp.makeConstraints {
            $0.top.equalTo(safeAreaLayoutGuide)
            $0.horizontalEdges.equalToSuperview()
        }
        
        cropContentView.snp.makeConstraints {
            $0.top.equalTo(topNavigationBar.snp.bottom)
            $0.horizontalEdges.bottom.equalToSuperview()
        }
    }
}
