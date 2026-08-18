//
//  WorkoutTitleEditView.swift
//  Routee-iOS
//
//  Created by 김세령 on 8/19/26.
//

import UIKit

import SnapKit
import Then

final class WorkoutTitleEditView: BaseUIView {

    // MARK: - Properties

    private let maxTitleLength = 16
    private var currentTitle = ""
    private var isEditingTitle = false

    // MARK: - UI Properties

    private let titleDisplayStackView = UIStackView()
    private let titleLabel = UILabel()
    private let titleEditingContainerView = UIView()
    private let titleTextField = UITextField()
    private let titleUnderlineView = UIView()
    private let editButton = UIButton()

    // MARK: - UI Setting

    override func setStyle() {
        titleDisplayStackView.do {
            $0.axis = .horizontal
            $0.alignment = .center
            $0.spacing = .s2
        }

        titleLabel.do {
            $0.font = .body_sb_14
            $0.textColor = .staticWhite
            $0.textAlignment = .left
            $0.lineBreakMode = .byTruncatingTail
            $0.numberOfLines = 1
            $0.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)
        }

        titleEditingContainerView.do {
            $0.isHidden = true
        }

        titleTextField.do {
            $0.font = .body_sb_14
            $0.textColor = .staticWhite
            $0.tintColor = .staticWhite
            $0.textAlignment = .left
            $0.borderStyle = .none
            $0.backgroundColor = .clear
            $0.returnKeyType = .done
            $0.isUserInteractionEnabled = false
            $0.delegate = self
        }

        titleUnderlineView.do {
            $0.backgroundColor = .statusInfo
            $0.alpha = 0
        }

        editButton.do {
            $0.setImage(UIImage(named: "ic_edit_sm_line_grey"), for: .normal)
            $0.backgroundColor = .clear
            $0.setContentHuggingPriority(.required, for: .horizontal)
            $0.setContentCompressionResistancePriority(.required, for: .horizontal)
        }
    }

    override func setUI() {
        addSubviews(
            titleDisplayStackView,
            titleEditingContainerView
        )

        titleDisplayStackView.addArrangedSubviews(
            titleLabel,
            editButton
        )

        titleEditingContainerView.addSubviews(
            titleTextField,
            titleUnderlineView
        )

        setActions()
    }

    override func setLayout() {
        snp.makeConstraints {
            $0.height.equalTo(20)
        }

        titleDisplayStackView.snp.makeConstraints {
            $0.center.equalToSuperview()
            $0.leading.greaterThanOrEqualToSuperview()
            $0.trailing.lessThanOrEqualToSuperview()
        }

        titleLabel.snp.makeConstraints {
            $0.width.lessThanOrEqualTo(120)
        }

        titleEditingContainerView.snp.makeConstraints {
            $0.verticalEdges.centerX.equalToSuperview()
            $0.width.equalTo(144)
        }

        titleUnderlineView.snp.makeConstraints {
            $0.horizontalEdges.equalToSuperview()
            $0.height.equalTo(1)
            $0.bottom.equalToSuperview()
        }

        titleTextField.snp.makeConstraints {
            $0.leading.equalTo(titleUnderlineView).offset(CGFloat.s4)
            $0.trailing.lessThanOrEqualTo(titleUnderlineView).inset(CGFloat.s4)
            $0.bottom.equalTo(titleUnderlineView.snp.top).offset(-CGFloat.s2)
            $0.width.equalTo(120)
            $0.height.equalTo(ceil(UIFont.body_sb_14.lineHeight))
        }

        editButton.snp.makeConstraints {
            $0.size.equalTo(24)
        }
    }

    // MARK: - Public Methods

    func configure(title: String) {
        currentTitle = String(title.prefix(maxTitleLength))
        updateTitleDisplay()
    }

    func endEditingIfNeeded() {
        guard isEditingTitle else { return }

        endTitleEditing()
    }

    // MARK: - Private Methods

    private func setActions() {
        editButton.addTarget(self, action: #selector(didTapEditButton), for: .touchUpInside)
    }

    private func updateTitleDisplay() {
        titleLabel.text = currentTitle
    }

    private func beginTitleEditing() {
        titleDisplayStackView.isHidden = true
        titleEditingContainerView.isHidden = false
        isEditingTitle = true
        titleUnderlineView.alpha = 1
        titleTextField.text = currentTitle
        titleTextField.isUserInteractionEnabled = true
        titleTextField.becomeFirstResponder()
    }

    private func endTitleEditing() {
        currentTitle = titleTextField.text ?? ""
        isEditingTitle = false
        titleTextField.isUserInteractionEnabled = false
        titleUnderlineView.alpha = 0
        titleEditingContainerView.isHidden = true
        titleDisplayStackView.isHidden = false
        updateTitleDisplay()
    }

    // MARK: - Actions

    @objc
    private func didTapEditButton() {
        beginTitleEditing()
    }
}

extension WorkoutTitleEditView: UITextFieldDelegate {

    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }

    func textFieldDidEndEditing(_ textField: UITextField) {
        endTitleEditing()
    }

    func textField(
        _ textField: UITextField,
        shouldChangeCharactersIn range: NSRange,
        replacementString string: String
    ) -> Bool {
        guard let text = textField.text,
              let textRange = Range(range, in: text) else {
            return false
        }

        let changedText = text.replacingCharacters(in: textRange, with: string)
        return changedText.count <= maxTitleLength
    }
}
