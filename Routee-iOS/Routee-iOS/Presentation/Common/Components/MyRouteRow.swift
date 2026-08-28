//
//  MyRouteRow.swift
//  Routee-iOS
//
//  Created by 초긍정행운의포춘쿠키 on 7/12/26.
//

import UIKit

import SnapKit
import Then

final class MyRouteRow: BaseUIView {

    // MARK: - UI Properties

    private let markerImageView = UIImageView()
    private let markerNumberLabel = UILabel()
    private let lineView = UIView()
    private let contentView = UIView()
    private let routeNameTextField = UITextField()
    private let removeButton = UIButton(type: .system)

    // MARK: - Properties

    var onTitleChange: ((String) -> Void)?
    var onRemoveTap: (() -> Void)?

    // MARK: - UI Setting

    override func setStyle() {
        backgroundColor = .clear

        markerImageView.do {
            $0.image = UIImage(named: "route_marker")
            $0.contentMode = .scaleAspectFit
        }

        markerNumberLabel.do {
            $0.font = .label_m_12
            $0.textColor = .grey_800
            $0.textAlignment = .center
        }

        lineView.do {
            $0.backgroundColor = .grey_400
        }

        contentView.do {
            $0.backgroundColor = .grey_800
            $0.layer.cornerRadius = .r12
        }

        routeNameTextField.do {
            $0.font = .label_m_14
            $0.textColor = .static_white
            $0.backgroundColor = .clear
            $0.borderStyle = .none
            $0.clearButtonMode = .never
            $0.returnKeyType = .done
            $0.delegate = self
            $0.attributedPlaceholder = NSAttributedString(
                string: "지점을 입력해주세요",
                attributes: [.foregroundColor: UIColor.grey_300]
            )
            $0.addTarget(self, action: #selector(textFieldDidChange), for: .editingChanged)
        }

        removeButton.do {
            $0.setImage(UIImage(named: "ic_minus_circle_sm"), for: .normal)
            $0.tintColor = .status_error
            $0.addTarget(self, action: #selector(removeButtonDidTap), for: .touchUpInside)
        }
    }

    override func setUI() {
        addSubviews(markerImageView, markerNumberLabel, lineView, contentView)
        contentView.addSubviews(routeNameTextField, removeButton)
    }

    override func setLayout() {
        snp.makeConstraints {
            $0.height.equalTo(60)
        }

        markerImageView.snp.makeConstraints {
            $0.top.equalToSuperview().inset(10)
            $0.leading.equalToSuperview().inset(4)
            $0.width.equalTo(20)
            $0.height.equalTo(24)
        }

        markerNumberLabel.snp.makeConstraints {
            $0.top.equalTo(markerImageView).offset(3)
            $0.centerX.equalTo(markerImageView)
        }

        contentView.snp.makeConstraints {
            $0.top.equalToSuperview()
            $0.leading.equalTo(markerImageView.snp.trailing).offset(12)
            $0.trailing.equalToSuperview()
            $0.height.equalTo(48)
        }

        lineView.snp.makeConstraints {
            $0.top.equalToSuperview().inset(42)
            $0.centerX.equalTo(markerImageView)
            $0.width.equalTo(1)
            $0.height.equalTo(18)
        }

        routeNameTextField.snp.makeConstraints {
            $0.leading.equalToSuperview().inset(12)
            $0.centerY.equalToSuperview()
            $0.trailing.equalTo(removeButton.snp.leading).offset(-12)
        }

        removeButton.snp.makeConstraints {
            $0.trailing.equalToSuperview().inset(12)
            $0.centerY.equalToSuperview()
            $0.size.equalTo(24)
        }
    }

    // MARK: - Public Methods

    func configure(
        number: Int,
        title: String,
        isLast: Bool,
        showsRemoveButton: Bool
    ) {
        markerNumberLabel.text = (1...20).contains(number) ? "\(number)" : nil
        routeNameTextField.text = title
        routeNameTextField.isUserInteractionEnabled = showsRemoveButton
        lineView.isHidden = isLast
        removeButton.isHidden = !showsRemoveButton
    }

    // MARK: - Private Methods

    @objc
    private func textFieldDidChange() {
        onTitleChange?(routeNameTextField.text ?? "")
    }

    @objc
    private func removeButtonDidTap() {
        onRemoveTap?()
    }
}

extension MyRouteRow: UITextFieldDelegate {

    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
}
