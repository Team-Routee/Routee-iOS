//
//  RouteeTextField.swift
//  Routee-iOS
//
//  Created by LEESANGYUP on 7/6/26.
//

import UIKit

import SnapKit

final class RouteeTextField: UITextField {
        
    private let textInsets = UIEdgeInsets(top: 0, left: .s12, bottom: 0, right: .s12)
    private let focusedBorderColor = UIColor.statusInfo
    private let unfocusedBorderColor = UIColor.white30
        
    init(placeholder: String = "닉네임을 입력해주세요") {
        super.init(frame: .zero)
        
        setStyle()
        setPlaceholder(placeholder)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func textRect(forBounds bounds: CGRect) -> CGRect {
        bounds.inset(by: textInsets)
    }
    
    override func editingRect(forBounds bounds: CGRect) -> CGRect {
        bounds.inset(by: textInsets)
    }
        
    func setPlaceholder(_ placeholder: String) {
        attributedPlaceholder = NSAttributedString(
            string: placeholder,
            attributes: [
                .font: UIFont.body_r_16,
                .foregroundColor: UIColor.white30
            ]
        )
    }
    
    private func setStyle() {
        backgroundColor = .dimPrimary
        textColor = .static_white
        tintColor = .static_white
        font = .body_r_16
        autocorrectionType = .no
        autocapitalizationType = .none
        
        layer.cornerRadius = .r12
        layer.borderWidth = 1
        layer.borderColor = unfocusedBorderColor.cgColor
        
        addTarget(self, action: #selector(didBeginEditing), for: .editingDidBegin)
        addTarget(self, action: #selector(didEndEditing), for: .editingDidEnd)
        
        self.snp.makeConstraints {
            $0.height.equalTo(50)
        }
    }
    
    @objc
    private func didBeginEditing() {
        layer.borderColor = focusedBorderColor.cgColor
    }
    
    @objc
    private func didEndEditing() {
        layer.borderColor = unfocusedBorderColor.cgColor
    }
}
