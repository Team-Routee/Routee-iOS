//
//  ProfileChangeViewController.swift
//  Routee-iOS
//
//  Created by 초긍정행운의포춘쿠키 on 8/26/26.
//

import PhotosUI
import UIKit

final class ProfileChangeViewController: BaseUIViewController {

    // MARK: - Properties

    private let viewModel = ProfileChangeViewModel()
    private var profileTask: Task<Void, Never>?
    private var updateTask: Task<Void, Never>?

    // MARK: - UI Properties

    private let rootView = ProfileChangeView()

    // MARK: - Life Cycle

    deinit {
        profileTask?.cancel()
        updateTask?.cancel()
    }

    override func loadView() {
        view = rootView
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        loadProfile()
    }

    // MARK: - Private Methods

    private func loadProfile() {
        profileTask?.cancel()
        profileTask = Task { [weak self] in
            guard let self else { return }

            do {
                try await loadLatestProfile()
            } catch {
                guard !Task.isCancelled else { return }

                RouteeLogger.error(error)
            }
        }
    }

    private func loadLatestProfile() async throws {
        let profile = try await viewModel.fetchProfile()

        guard !Task.isCancelled else { return }

        await MainActor.run {
            rootView.configure(with: profile)
        }
    }

    private func presentImagePicker() {
        var configuration = PHPickerConfiguration()
        configuration.filter = .images
        configuration.selectionLimit = 1

        let picker = PHPickerViewController(configuration: configuration)
        picker.delegate = self

        present(picker, animated: true)
    }

    private func presentProfileImageModal() {
        let modal = ActionVerticalModal(
            title: "프로필 사진 설정",
            topButtonTitle: "앨범에서 선택",
            bottomButtonTitle: "기본 이미지 적용",
            topButtonAction: { [weak self] in
                self?.presentImagePicker()
            },
            bottomButtonAction: { [weak self] in
                self?.applyDefaultProfileImage()
            }
        )

        present(modal, animated: true)
    }

    private func handleCameraButtonTap() {
        if rootView.shouldPresentProfileImageModal {
            presentProfileImageModal()
        } else {
            presentImagePicker()
        }
    }

    private func applyDefaultProfileImage() {
        rootView.applyDefaultProfileImage()
    }

    private func pushProfileImageCropView(with image: UIImage) {
        let imageCropViewController = ProfileImageCropViewController(image: image)

        imageCropViewController.onCropCompleted = { [weak self] croppedImage in
            self?.rootView.updateProfileImage(croppedImage)
        }

        navigationController?.pushViewController(imageCropViewController, animated: false)
        navigationController?.navigationBar.isHidden = true
    }

    private func updateProfile() {
        updateTask?.cancel()
        updateTask = Task { [weak self] in
            guard let self else { return }

            do {
                try await viewModel.updateProfile(
                    nickname: rootView.nickname,
                    hasNicknameChanged: rootView.hasNicknameChanged,
                    shouldApplyDefaultProfileImage: rootView.shouldApplyDefaultProfileImage,
                    profileImage: rootView.selectedProfileImage
                )

                try await loadLatestProfile()

                await MainActor.run {
                    self.rootView.showToast(title: "변경이 저장되었습니다.")
                }
            } catch {
                guard !Task.isCancelled else { return }

                RouteeLogger.error(error)
            }
        }
    }

    // MARK: - Actions

    override func setAddTarget() {
        rootView.backButtonAction = { [weak self] in
            self?.navigationController?.popViewController(animated: true)
        }

        rootView.cameraButtonAction = { [weak self] in
            self?.handleCameraButtonTap()
        }

        rootView.changeButtonAction = { [weak self] in
            self?.updateProfile()
        }
    }
}

// MARK: - PHPickerViewControllerDelegate

extension ProfileChangeViewController: PHPickerViewControllerDelegate {

    func picker(
        _ picker: PHPickerViewController,
        didFinishPicking results: [PHPickerResult]
    ) {
        guard let result = results.first else {
            picker.dismiss(animated: true)
            return
        }

        result.itemProvider.loadObject(ofClass: UIImage.self) { [weak self] object, _ in
            guard let image = object as? UIImage else { return }

            DispatchQueue.main.async {
                picker.dismiss(animated: true) {
                    self?.pushProfileImageCropView(with: image)
                }
            }
        }
    }
}
