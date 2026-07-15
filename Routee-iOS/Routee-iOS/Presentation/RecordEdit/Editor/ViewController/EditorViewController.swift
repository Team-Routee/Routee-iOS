//
//  EditorViewController.swift
//  Routee-iOS
//
//  Created by 김세령 on 7/8/26.
//

import PhotosUI
import UIKit

import SnapKit
import Then

final class EditorViewController: BaseUIViewController {

    // MARK: - Properties

    private let viewModel = EditorViewModel()
    private let activityId: Int64

    // MARK: - UI Properties

    private let rootView = EditorView()

    // MARK: - Initializer

    init(activityId: Int64) {
        self.activityId = activityId
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError()
    }

    // MARK: - Life Cycle

    override func loadView() {
        view = rootView
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        loadActivityEditorData()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        (tabBarController as? TabBarViewController)?.setCustomTabBarHidden(true)
    }

    // MARK: - Private Methods

    private func loadActivityEditorData() {
        Task { [weak self] in
            guard let self else { return }

            do {
                try await viewModel.fetchActivityEditorData(activityId: activityId)

                guard let activityEditorModel = viewModel.activityEditorModel else { return }

                    rootView.configure(with: activityEditorModel)

            } catch {
                RouteeLogger.error(error)
            }
        }
    }

    private func popViewController() {
        navigationController?.popViewController(animated: false)
    }

    private func presentImagePicker() {
        var configuration = PHPickerConfiguration()
        configuration.filter = .images
        configuration.selectionLimit = 1

        let picker = PHPickerViewController(configuration: configuration)
        picker.delegate = self

        present(picker, animated: true)
    }

    private func pushCropView(with image: UIImage) {
        let imageCropViewController = ImageCropViewController(image: image)

        imageCropViewController.onCropCompleted = { [weak self] croppedImage in
            self?.rootView.updateBackgroundImage(croppedImage)
        }

        navigationController?.pushViewController(imageCropViewController, animated: false)
        navigationController?.navigationBar.isHidden = true
    }

    private func pushCompleteView() {
        let editedImage = rootView.makeEditedImage()
        let editCompleteViewController = EditCompleteViewController(editedImage: editedImage)

        navigationController?.pushViewController(editCompleteViewController, animated: false)
        navigationController?.navigationBar.isHidden = true
    }

    // MARK: - Actions

    override func setAddTarget() {
        rootView.setGesture()
        rootView.setAddTarget()
        rootView.setInitialState()

        rootView.topNavigationBar.backButtonAction = { [weak self] in
            self?.popViewController()
        }

        rootView.topNavigationBar.rightButtonAction = { [weak self] in
            self?.rootView.playLottie {
                self?.pushCompleteView()
            }
        }

        rootView.setBackgroundTapAction { [weak self] in
            self?.presentImagePicker()
        }
    }
}

// MARK: - PHPickerViewControllerDelegate

extension EditorViewController: PHPickerViewControllerDelegate {

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
                    self?.pushCropView(with: image)
                }
            }
        }
    }
}
