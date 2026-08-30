//
//  ProfileChangeView.swift
//  Routee-iOS
//
//  Created by 초긍정행운의포춘쿠키 on 8/26/26.
//

import UIKit

import Kingfisher
import SnapKit
import Then

final class ProfileChangeView: BaseUIView {
    
    // MARK: - Properties
    
    var backButtonAction: (() -> Void)?
    var cameraButtonAction: (() -> Void)?
    var changeButtonAction: (() -> Void)?

    var nickname: String {
        nicknameTextField.text ?? ""
    }

    var hasNicknameChanged: Bool {
        nickname != initialNickname
    }

    var shouldPresentProfileImageModal: Bool {
        !isDefaultProfileImageApplied && (initialProfileImageUrl != nil || selectedProfileImage != nil)
    }

    var shouldApplyDefaultProfileImage: Bool {
        initialProfileImageUrl != nil && isDefaultProfileImageApplied
    }

    var selectedProfileImage: UIImage?

    private var initialNickname = ""
    private var initialProfileImageUrl: String?
    private var isNicknameValid = false
    private var isDefaultProfileImageApplied = false
    
    // MARK: - UI Properties
    
    private let backgroundGradientView = RouteeEllipseBackground()
    private let topNavigationBar = TopNavigationBar(title: "프로필 변경")
    private let profileImageView = UIImageView()
    private let cameraButton = UIButton()
    private let nicknameTextField = NicknameTextField(fieldCase: .profile)
    private let changeButton = RouteeButton(titleText: "변경하기", type: .disabled)
    
    // MARK: - UI Setting
    
    override func setStyle() {
        backgroundColor = .bgPrimary

        profileImageView.do {
            $0.image = .profileImgDefault
            $0.contentMode = .scaleAspectFill
            $0.layer.cornerRadius = 56.5
            $0.clipsToBounds = true
        }

        cameraButton.do {
            $0.setImage(.btnCameraSm, for: .normal)
        }

        nicknameTextField.validationChanged = { [weak self] isValid in
            self?.isNicknameValid = isValid
            self?.updateChangeButtonState()
        }
    }

    override func setUI() {
        addSubviews(
            backgroundGradientView,
            topNavigationBar,
            profileImageView,
            cameraButton,
            nicknameTextField,
            changeButton
        )

        setAddTarget()
    }

    override func setLayout() {
        backgroundGradientView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }

        topNavigationBar.snp.makeConstraints {
            $0.top.equalTo(safeAreaLayoutGuide).offset(10)
            $0.horizontalEdges.equalToSuperview()
        }

        profileImageView.snp.makeConstraints {
            $0.top.equalTo(topNavigationBar.snp.bottom).offset(51)
            $0.centerX.equalToSuperview()
            $0.size.equalTo(113)
        }

        cameraButton.snp.makeConstraints {
            $0.trailing.bottom.equalTo(profileImageView)
            $0.size.equalTo(36)
        }

        nicknameTextField.snp.makeConstraints {
            $0.top.equalTo(profileImageView.snp.bottom).offset(42)
            $0.centerX.equalToSuperview()
        }

        changeButton.snp.makeConstraints {
            $0.bottom.equalTo(safeAreaLayoutGuide).inset(28)
            $0.centerX.equalToSuperview()
        }
    }

    // MARK: - Public Methods

    func configure(with profile: ProfileModel) {
        initialNickname = profile.nickname
        initialProfileImageUrl = profile.profileImageUrl
        selectedProfileImage = nil
        isDefaultProfileImageApplied = false
        nicknameTextField.configure(nickname: profile.nickname)
        configureProfileImage(with: profile.profileImageUrl)
        updateChangeButtonState()
    }

    func updateProfileImage(_ image: UIImage) {
        selectedProfileImage = image
        isDefaultProfileImageApplied = false
        profileImageView.image = image
        updateChangeButtonState()
    }

    func applyDefaultProfileImage() {
        let defaultProfileImage = UIImage(resource: .profileImgDefault)
        selectedProfileImage = nil
        isDefaultProfileImageApplied = true
        profileImageView.image = defaultProfileImage
        updateChangeButtonState()
    }

    // MARK: - Private Methods

    private func setAddTarget() {
        topNavigationBar.backButtonAction = { [weak self] in
            self?.backButtonAction?()
        }

        cameraButton.addTarget(self, action: #selector(didTapCameraButton), for: .touchUpInside)
        changeButton.addTarget(self, action: #selector(didTapChangeButton), for: .touchUpInside)
    }

    private func configureProfileImage(with imageUrl: String?) {
        profileImageView.image = .profileImgDefault

        guard let imageUrl,
              let url = URL(string: imageUrl) else { return }

        profileImageView.kf.setImage(with: url, placeholder: UIImage(resource: .profileImgDefault))
    }

    private func updateChangeButtonState() {
        let hasProfileImageChanged = selectedProfileImage != nil || shouldApplyDefaultProfileImage
        let canSubmit = isNicknameValid && (hasNicknameChanged || hasProfileImageChanged)

        changeButton.updateType(canSubmit ? .enabled : .disabled)
    }

    // MARK: - Actions

    @objc
    private func didTapCameraButton() {
        cameraButtonAction?()
    }

    @objc
    private func didTapChangeButton() {
        changeButtonAction?()
    }
}
