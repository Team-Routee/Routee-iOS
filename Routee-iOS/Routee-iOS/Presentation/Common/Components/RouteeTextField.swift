//
//  RouteeTextField.swift
//  Routee-iOS
//
//  Created by LEESANGYUP on 7/6/26.
//

import UIKit

import SnapKit

final class RouteeTextField: UITextField {

    var trailingIconAction: (() -> Void)?

    private let textInsets = UIEdgeInsets(top: 0, left: 12, bottom: 0, right: 12)
    private let iconSize: CGFloat = 24
    private let iconTextSpacing: CGFloat = 8
    private let focusedBorderColor = UIColor.statusInfo
    private let unfocusedBorderColor = UIColor.white30
    private let fieldHeight: CGFloat

    init(
        placeholder: String = "닉네임을 입력해주세요",
        icon: UIImage? = nil,
        trailingIcon: UIImage? = nil,
        height: CGFloat = 56
    ) {
        fieldHeight = height
        super.init(frame: .zero)

        setStyle()
        setPlaceholder(placeholder)
        if let icon { setLeadingIcon(icon) }
        if let trailingIcon { setTrailingIcon(trailingIcon) }
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

    override func rightViewRect(forBounds bounds: CGRect) -> CGRect {
        CGRect(
            x: bounds.width - textInsets.right - iconSize,
            y: (bounds.height - iconSize) / 2,
            width: iconSize,
            height: iconSize
        )
    }

    private var textAreaInsets: UIEdgeInsets {
        var insets = textInsets
        if leftView != nil {
            insets.left += iconSize + iconTextSpacing
        }
        if rightView != nil {
            insets.right += iconSize + iconTextSpacing
        }
        return insets
    }

    private func setLeadingIcon(_ icon: UIImage) {
        let imageView = UIImageView(image: icon)
        imageView.contentMode = .scaleAspectFit
        leftView = imageView
        leftViewMode = .always
    }

    private func setTrailingIcon(_ icon: UIImage) {
        let button = UIButton()
        button.setImage(icon, for: .normal)
        button.addTarget(self, action: #selector(didTapTrailingIcon), for: .touchUpInside)
        rightView = button
        rightViewMode = .always
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
            $0.height.equalTo(fieldHeight)
        }
    }

    @objc
    private func didTapTrailingIcon() {
        trailingIconAction?()
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
