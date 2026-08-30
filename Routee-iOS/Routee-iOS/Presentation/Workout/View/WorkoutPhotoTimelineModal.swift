//
//  WorkoutPhotoTimelineModal.swift
//  Routee-iOS
//
//  Created by LEESANGYUP on 8/29/26.
//

import UIKit

import SnapKit
import Then

final class WorkoutPhotoTimelineModal: BaseUIView {

    // MARK: - Properties

    var deleteButtonAction: (() -> Void)?
    var closeButtonAction: (() -> Void)?
    var titleChangedAction: ((String) -> Void)?

    var titleText: String {
        titleTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
    }

    private let maxTitleLength = 16

    // MARK: - UI Properties

    private let deleteButton = UIButton()
    private let closeButton = UIButton()
    private let photoImageView = UIImageView()
    private let titleTextField = RouteeTextField(
        placeholder: "현재 위치를 남겨주세요.",
        trailingIcon: UIImage(named: "ic_edit_sm_line_white"),
        height: 44
    )
    private let titleCountLabel = UILabel()

    // MARK: - Initializer

    convenience init(image: UIImage?, title: String) {
        self.init(frame: .zero)
        configure(image: image, title: title)
    }

    // MARK: - UI Setting

    override func setStyle() {
        backgroundColor = .grey_800
        layer.cornerRadius = .r24
        clipsToBounds = true

        deleteButton.do {
            $0.setImage(UIImage(named: "ic_delete_lg"), for: .normal)
            $0.backgroundColor = .grey_900
            $0.layer.cornerRadius = .r16
        }

        closeButton.do {
            $0.setImage(UIImage(named: "ic_cancel_sm_outline"), for: .normal)
            $0.backgroundColor = .white_10
            $0.layer.cornerRadius = .r16
        }

        photoImageView.do {
            $0.contentMode = .scaleAspectFill
            $0.clipsToBounds = true
            $0.layer.cornerRadius = .r12
        }

        titleTextField.do {
            $0.font = .label_m_14
            $0.textColor = .staticWhite
            $0.tintColor = .staticWhite
            $0.backgroundColor = .grey_900
            $0.layer.borderColor = UIColor.white30.cgColor
            $0.returnKeyType = .done
            $0.clearButtonMode = .never
            $0.delegate = self
        }

        titleCountLabel.do {
            $0.font = .label_m_14
            $0.textColor = .white30
            $0.textAlignment = .right
        }
    }

    override func setUI() {
        addSubviews(
            deleteButton,
            closeButton,
            photoImageView,
            titleTextField,
            titleCountLabel
        )

        setActions()
    }

    override func setLayout() {
        snp.makeConstraints {
            $0.width.equalTo(320)
            $0.height.equalTo(430)
        }

        deleteButton.snp.makeConstraints {
            $0.top.equalToSuperview().inset(CGFloat.s20)
            $0.leading.equalToSuperview().inset(CGFloat.s24)
            $0.size.equalTo(32)
        }

        closeButton.snp.makeConstraints {
            $0.top.equalToSuperview().inset(CGFloat.s20)
            $0.trailing.equalToSuperview().inset(CGFloat.s24)
            $0.size.equalTo(32)
        }

        photoImageView.snp.makeConstraints {
            $0.top.equalToSuperview().inset(64)
            $0.horizontalEdges.equalToSuperview().inset(CGFloat.s24)
            $0.height.equalTo(264)
        }

        titleTextField.snp.makeConstraints {
            $0.top.equalTo(photoImageView.snp.bottom).offset(CGFloat.s12)
            $0.horizontalEdges.equalToSuperview().inset(CGFloat.s24)
        }

        titleCountLabel.snp.makeConstraints {
            $0.top.equalTo(titleTextField.snp.bottom).offset(CGFloat.s2)
            $0.trailing.equalToSuperview().inset(CGFloat.s24)
            $0.height.equalTo(20)
        }
    }

    // MARK: - Public Methods

    func configure(image: UIImage?, title: String) {
        photoImageView.image = image
        let limitedTitle = String(title.prefix(maxTitleLength))
        titleTextField.text = limitedTitle
        updateCharacterCount()
    }

    // MARK: - Private Methods

    private func updateCharacterCount() {
        titleCountLabel.text = "\(titleTextField.text?.count ?? 0)/\(maxTitleLength)"
    }
    
    private func setActions() {
        deleteButton.addTarget(self, action: #selector(didTapDeleteButton), for: .touchUpInside)
        closeButton.addTarget(self, action: #selector(didTapCloseButton), for: .touchUpInside)
        titleTextField.addTarget(self, action: #selector(titleTextDidChange), for: .editingChanged)
        titleTextField.trailingIconAction = { [weak self] in
            self?.titleTextField.becomeFirstResponder()
        }
    }

    // MARK: - Actions

    @objc
    private func didTapDeleteButton() {
        deleteButtonAction?()
    }

    @objc
    private func didTapCloseButton() {
        endEditing(true)
        closeButtonAction?()
    }

    @objc
    private func titleTextDidChange() {
        updateCharacterCount()
        titleChangedAction?(titleTextField.text ?? "")
    }
}

// MARK: - UITextFieldDelegate

extension WorkoutPhotoTimelineModal: UITextFieldDelegate {
    func textField(
        _ textField: UITextField,
        shouldChangeCharactersIn range: NSRange,
        replacementString string: String
    ) -> Bool {
        guard let currentText = textField.text,
              let textRange = Range(range, in: currentText) else { return false }

        let updatedText = currentText.replacingCharacters(in: textRange, with: string)
        return updatedText.count <= maxTitleLength
    }

    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
}
