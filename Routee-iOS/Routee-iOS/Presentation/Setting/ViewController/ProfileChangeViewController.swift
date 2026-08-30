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

    // MARK: - UI Properties

    private let rootView = ProfileChangeView()

    // MARK: - Life Cycle

    deinit {
        profileTask?.cancel()
    }

    override func loadView() {
        view = rootView
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        fetchProfile()
    }

    // MARK: - Private Methods

    private func fetchProfile() {
        profileTask?.cancel()
        profileTask = Task { [weak self] in
            guard let self else { return }

            do {
                let profile = try await viewModel.fetchProfile()
                rootView.configure(with: profile)
            } catch {
                guard !Task.isCancelled else { return }

                RouteeLogger.error(error)
            }
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

    private func pushProfileImageCropView(with image: UIImage) {
        let imageCropViewController = ImageCropViewController(
            image: image,
            aspectRatioPreset: CGSize(width: 1, height: 1)
        )

        imageCropViewController.onCropCompleted = { [weak self] croppedImage in
            self?.rootView.updateProfileImage(croppedImage)
        }

        navigationController?.pushViewController(imageCropViewController, animated: false)
        navigationController?.navigationBar.isHidden = true
    }

    private func updateProfile() {
        profileTask?.cancel()
        profileTask = Task { [weak self] in
            guard let self else { return }

            do {
                try await viewModel.updateProfile(
                    nickname: rootView.nickname,
                    hasNicknameChanged: rootView.hasNicknameChanged,
                    profileImage: rootView.selectedProfileImage
                )

                navigationController?.popViewController(animated: true)
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
            self?.presentImagePicker()
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
