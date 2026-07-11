//
//  ToastMessageView.swift
//  Routee-iOS
//
//  Created by 김세령 on 7/11/26.
//

import UIKit

import SnapKit
import Then

final class ToastMessageView: BaseUIView {
    
    // MARK: - UI Properties
    
    let titleLabel = UILabel()
    
    // MARK: - init
    
    init(title: String) {
        super.init(frame: .zero)
        titleLabel.text = title
    }
    
    required init?(coder: NSCoder) {
        fatalError()
    }
    
    // MARK: - UI Setting
    
    override func setStyle() {
        backgroundColor = .grey_800
        
        titleLabel.do {
            $0.textColor = .staticWhite
            $0.font = .label_m_14
            $0.textAlignment = .center
            $0.numberOfLines = 1
            $0.lineBreakMode = .byTruncatingTail
        }
    }   
    
    override func setUI() {
        addSubview(titleLabel)
    }
    
    override func setLayout() {
        titleLabel.snp.makeConstraints {
            $0.horizontalEdges.equalToSuperview().inset(16)
            $0.centerY.equalToSuperview()
        }
    }
}
