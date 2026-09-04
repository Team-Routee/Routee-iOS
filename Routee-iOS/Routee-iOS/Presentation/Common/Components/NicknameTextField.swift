//
//  NickNameTextField.swift
//  Routee-iOS
//
//  Created by 초긍정행운의포춘쿠키 on 8/17/26.
//

import UIKit

import SnapKit
import Then

final class NicknameTextField: UITextField {

    // MARK: - Properties

    enum NicknameTextFieldCase {
        case onboarding
        case profile
    }

    var validationChanged: ((Bool) -> Void)?

    private enum NicknameValidationState {
        case guide
        case valid
        case invalid
    }

    private let textInsets = UIEdgeInsets(top: 0, left: .s12, bottom: 0, right: .s12)
    private let iconSize: CGFloat = 24
    private let editIconSize: CGFloat = 26
    private let focusedBorderColor = UIColor.statusInfo
    private let unfocusedBorderColor = UIColor.white30
    private let errorBorderColor = UIColor.statusError
    private let guideText = "한글, 영문, 숫자만 입력 가능해요 (공백 연속 불가, 최대 12자)"
    private let fieldCase: NicknameTextFieldCase
    private let initialNickname: String?
    private let placeholderText: String

    private var textAreaInsets: UIEdgeInsets {
        var insets = textInsets
        if rightViewMode == .always {
            insets.right += currentStatusIconSize + textInsets.right
        }
        return insets
    }

    // MARK: - UI Properties

    private let nicknameGuideLabel = UILabel()
    private let statusIconContainer = UIView()
    private let statusImageView = UIImageView()
    private var currentStatusIconSize: CGFloat = 24

    // MARK: - Initializer

    init(
        fieldCase: NicknameTextFieldCase = .onboarding,
        nickname: String? = nil,
        placeholder: String = "닉네임을 입력해주세요"
    ) {
        self.fieldCase = fieldCase
        self.initialNickname = nickname
        self.placeholderText = placeholder
        super.init(frame: .zero)

        setStyle()
        setUI()
        setLayout()
        setAddTarget()
        setInitialState()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Override Methods

    override func textRect(forBounds bounds: CGRect) -> CGRect {
        bounds.inset(by: textAreaInsets)
    }

    override func editingRect(forBounds bounds: CGRect) -> CGRect {
        bounds.inset(by: textAreaInsets)
    }

    override func canPerformAction(_ action: Selector, withSender sender: Any?) -> Bool {
        guard action != #selector(paste(_:)) else { return false }

        return super.canPerformAction(action, withSender: sender)
    }

    // MARK: - UI Setting
    
    private func setStyle() {
        backgroundColor = .dimPrimary
        textColor = .static_white
        tintColor = .static_white
        font = .body_r_16
        autocorrectionType = .no
        autocapitalizationType = .none
        returnKeyType = .done
        delegate = self
        setPlaceholder()
        
        layer.cornerRadius = .r12
        layer.borderWidth = 1
        layer.borderColor = unfocusedBorderColor.cgColor

        nicknameGuideLabel.do {
            $0.text = guideText
            $0.textColor = .white60
            $0.font = .label_r_12
        }

        statusImageView.contentMode = .scaleAspectFit
    }

    private func setPlaceholder() {
        attributedPlaceholder = NSAttributedString(
            string: placeholderText,
            attributes: [
                .font: UIFont.body_r_16,
                .foregroundColor: UIColor.white30
            ]
        )
    }

    private func setUI() {
        addSubview(nicknameGuideLabel)

        setStatusIconContainerFrame()
        statusIconContainer.addSubview(statusImageView)
        rightView = statusIconContainer
        rightViewMode = .never
    }

    private func setAddTarget() {
        addTarget(self, action: #selector(didBeginEditing), for: .editingDidBegin)
        addTarget(self, action: #selector(didEndEditing), for: .editingDidEnd)
        addTarget(self, action: #selector(didChangeText), for: .editingChanged)
        statusIconContainer.addGestureRecognizer(
            UITapGestureRecognizer(target: self, action: #selector(didTapStatusIcon))
        )
    }

    private func setLayout() {
        nicknameGuideLabel.snp.makeConstraints {
            $0.leading.equalToSuperview()
            $0.top.equalTo(snp.bottom).offset(6)
        }
        
        self.snp.makeConstraints {
            $0.width.equalTo(311)
            $0.height.equalTo(50)
        }
    }
    
    // MARK: - Actions
    
    @objc
    private func didBeginEditing() {
        updateState(for: text ?? "", isEditing: true)
    }
    
    @objc
    private func didEndEditing() {
        let trimmedText = text?.trimmingCharacters(in: .whitespaces) ?? ""
        text = trimmedText
        updateState(for: trimmedText, isEditing: false)
    }

    @objc
    private func didChangeText() {
        updateState(for: text ?? "", isEditing: isEditing)
    }

    @objc
    private func didTapStatusIcon() {
        becomeFirstResponder()
    }

    // MARK: - Public Methods

    func configure(nickname: String) {
        text = nickname
        updateState(for: nickname, isEditing: isEditing)
    }

    // MARK: - Private Methods

    private func setInitialState() {
        setGuideLabel(color: .white60)

        switch fieldCase {
        case .onboarding:
            hideStatusIcon()

        case .profile:
            text = initialNickname
            showStatusIcon(.icEditSmLineWhite, size: editIconSize)
        }
    }

    private func updateState(for text: String, isEditing: Bool) {
        let validationState = validationState(for: text)

        switch validationState {
        case .guide:
            layer.borderColor = isEditing ? focusedBorderColor.cgColor : unfocusedBorderColor.cgColor
            setGuideLabel(color: .white60)
            hideStatusIcon()

        case .valid:
            layer.borderColor = isEditing ? focusedBorderColor.cgColor : unfocusedBorderColor.cgColor
            setGuideLabel(color: .white60)
            showStatusIcon(.icSuccess, size: iconSize)

        case .invalid:
            layer.borderColor = errorBorderColor.cgColor
            setGuideLabel(color: .statusError)
            showStatusIcon(.icError, size: iconSize)
        }

        validationChanged?(validationState == .valid)
    }

    private func setGuideLabel(color: UIColor) {
        nicknameGuideLabel.text = guideText
        nicknameGuideLabel.textColor = color
        nicknameGuideLabel.isHidden = false
    }

    private func setStatusIconContainerFrame() {
        statusIconContainer.frame = CGRect(
            x: 0,
            y: 0,
            width: currentStatusIconSize + textInsets.right,
            height: currentStatusIconSize
        )
        statusImageView.frame = CGRect(
            x: 0,
            y: 0,
            width: currentStatusIconSize,
            height: currentStatusIconSize
        )
    }

    private func showStatusIcon(_ image: ImageResource, size: CGFloat) {
        currentStatusIconSize = size
        setStatusIconContainerFrame()
        statusImageView.image = UIImage(resource: image)
        rightViewMode = .always
    }

    private func hideStatusIcon() {
        rightViewMode = .never
    }

    private func validationState(for text: String) -> NicknameValidationState {
        guard !text.isEmpty else { return .guide }
        guard text.count <= 12 else { return .invalid }
        guard !text.contains("  ") else {
            return .invalid
        }
        guard text.range(of: "^[가-힣A-Za-z0-9 ]+$", options: .regularExpression) != nil else {
            return .invalid
        }
        return .valid
    }
}

extension NicknameTextField: UITextFieldDelegate {
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        true
    }

    func textField(
        _ textField: UITextField,
        shouldChangeCharactersIn range: NSRange,
        replacementString string: String
    ) -> Bool {
        guard let currentText = textField.text,
              let textRange = Range(range, in: currentText) else {
            return false
        }

        let updatedText = currentText.replacingCharacters(in: textRange, with: string)
        guard updatedText.count <= 12 else { return false }
        guard !updatedText.hasPrefix(" ") else { return false }
        guard !updatedText.contains("  ") else { return false }

        return true
    }

    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
}
