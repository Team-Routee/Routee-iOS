//
//  TitleTextField.swift
//  Routee-iOS
//
//  Created by LEESANGYUP on 7/11/26.
//

import UIKit

import SnapKit
import Then

final class TitleTextField: BaseUIView {
    private let title: String
    private let showsEditIcon: Bool
    
    var text: String? {
        titleTextField.text
    }
    
    private let titleTextField = UITextField()
    private let editButton = UIButton()
    
    init(title: String, showsEditIcon: Bool) {
        self.title = title
        self.showsEditIcon = showsEditIcon
        
        super.init(frame: .zero)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func setStyle() {
        titleTextField.do {
            $0.text = title
            $0.font = .title_sb_20
            $0.textColor = .staticWhite
            $0.tintColor = .staticWhite
            $0.borderStyle = .none
            $0.returnKeyType = .done
            $0.isUserInteractionEnabled = false
            $0.delegate = self
        }
        
        editButton.do {
            $0.setImage(UIImage(resource: .icEditSmLineWhite), for: .normal)
            $0.isHidden = !showsEditIcon
            $0.isUserInteractionEnabled = showsEditIcon
        }
    }
    
    override func setUI() {
        addSubviews(titleTextField, editButton)
        
        setActions()
    }
    
    override func setLayout() {
        snp.makeConstraints {
            $0.height.equalTo(44)
        }
        
        titleTextField.snp.makeConstraints {
            $0.leading.equalToSuperview().inset(16)
            $0.centerY.equalToSuperview()
            $0.trailing.lessThanOrEqualTo(editButton.snp.leading).offset(-16)
            $0.height.equalTo(44)
        }
        
        editButton.snp.makeConstraints {
            $0.trailing.equalToSuperview().inset(26)
            $0.centerY.equalToSuperview()
            $0.size.equalTo(24)
        }
    }
    
    private func setActions() {
        editButton.addTarget(self, action: #selector(didTapEditButton), for: .touchUpInside)
    }
    
    @objc
    private func didTapEditButton() {
        titleTextField.isUserInteractionEnabled = true
        titleTextField.becomeFirstResponder()
    }
}

extension TitleTextField: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        textField.isUserInteractionEnabled = false
    }
}
