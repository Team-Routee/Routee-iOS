//
//  RouteeButton.swift
//  Routee-iOS
//
//  Created by LEESANGYUP on 7/6/26.
//

import UIKit

import SnapKit
import Then

enum RouteeButtonType {
    case enabled
    case disabled
    
    var backgroundColor: UIColor {
        switch self {
        case .enabled:
                .bgCtaPrimary
        case .disabled:
                .grey600
        }
    }
    
    var textColor: UIColor {
        switch self {
        case .enabled:
                .staticBlack
        case .disabled:
                .grey200
        }
    }
    
    var isEnabled: Bool {
        switch self {
        case .enabled:
            true
        case .disabled:
            false
        }
    }
}

final class RouteeButton: UIButton {
    private let titleText: String
    private var type: RouteeButtonType
    
    override var isHighlighted: Bool {
        didSet {
            updateBackgroundColor()
        }
    }
    
    init(
        titleText: String,
        type: RouteeButtonType
    ) {
        self.titleText = titleText
        self.type = type
        
        super.init(frame: .zero)
        
        self.setTitle(titleText, for: .normal)
        self.setTitleColor(type.textColor, for: .normal)
        self.titleLabel?.font = .label_sb_16
        self.layer.cornerRadius = 27
        self.isEnabled = type.isEnabled
        updateBackgroundColor()
        
        self.snp.makeConstraints {
            $0.height.equalTo(54)
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func updateType(_ type: RouteeButtonType) {
        self.do {
            $0.type = type
            $0.setTitleColor(type.textColor, for: .normal)
            $0.isEnabled = type.isEnabled
            $0.updateBackgroundColor()
        }
    }
    
    private func updateBackgroundColor() {
        guard type.isEnabled else {
            backgroundColor = type.backgroundColor
            return
        }
        
        backgroundColor = isHighlighted ? .mint_200 : type.backgroundColor
    }
}
