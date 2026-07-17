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
    private let iconSize: CGFloat = 24
    private let iconTextSpacing: CGFloat = 8
    private let focusedBorderColor = UIColor.statusInfo
    private let unfocusedBorderColor = UIColor.white30

    init(placeholder: String = "닉네임을 입력해주세요", icon: UIImage? = nil) {
        super.init(frame: .zero)

        setStyle()
        setPlaceholder(placeholder)
        if let icon { setLeadingIcon(icon) }
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func textRect(forBounds bounds: CGRect) -> CGRect {
        bounds.inset(by: textAreaInsets)
    }

    override func editingRect(forBounds bounds: CGRect) -> CGRect {
        bounds.inset(by: textAreaInsets)
    }

    override func leftViewRect(forBounds bounds: CGRect) -> CGRect {
        CGRect(
            x: textInsets.left,
            y: (bounds.height - iconSize) / 2,
            width: iconSize,
            height: iconSize
        )
    }

    private var textAreaInsets: UIEdgeInsets {
        guard leftView != nil else { return textInsets }

        var insets = textInsets
        insets.left += iconSize + iconTextSpacing
        return insets
    }

    private func setLeadingIcon(_ icon: UIImage) {
        let imageView = UIImageView(image: icon)
        imageView.contentMode = .scaleAspectFit
        leftView = imageView
        leftViewMode = .always
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
