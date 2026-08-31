//
//  ProfileImageCropViewController.swift
//  Routee-iOS
//
//  Created by 초긍정행운의포춘쿠키 on 8/31/26.
//

import UIKit

import CropViewController
import TOCropViewController

final class ProfileImageCropViewController: BaseUIViewController {

    // MARK: - Properties

    var onCropCompleted: ((UIImage) -> Void)?
    private let cropViewController: CropViewController

    // MARK: - UI Property

    private let rootView: ImageCropView

    // MARK: - Initializer

    init(image: UIImage) {
        let cropViewController = CropViewController(image: image)

        self.cropViewController = cropViewController
        self.rootView = ImageCropView(cropContentView: cropViewController.view)
        super.init(nibName: nil, bundle: nil)
        hidesBottomBarWhenPushed = true
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - UI Setting

    override func loadView() {
        view = rootView
    }

    override func setView() {
        setCropViewController()

        addChild(cropViewController)
        cropViewController.didMove(toParent: self)
    }

    // MARK: - Private Methods

    private func setCropViewController() {
        cropViewController.delegate = self
        cropViewController.aspectRatioPreset = CGSize(width: 1, height: 1)
        cropViewController.aspectRatioLockEnabled = true
        cropViewController.resetAspectRatioEnabled = false
        cropViewController.hidesNavigationBar = false

        setCropToolbarButtons()
    }

    private func setCropToolbarButtons() {
        cropViewController.doneButtonHidden = true
        cropViewController.cancelButtonHidden = true
        cropViewController.aspectRatioPickerButtonHidden = true

        cropViewController.toolbar.doneButtonHidden = true
        cropViewController.toolbar.cancelButtonHidden = true
        cropViewController.toolbar.rotateCounterclockwiseButtonHidden = false
        cropViewController.toolbar.rotateClockwiseButtonHidden = false
        cropViewController.toolbar.resetButtonHidden = false
        cropViewController.toolbar.clampButtonHidden = true
        cropViewController.toolbar.resetButtonEnabled = true
    }

    private func popViewController() {
        navigationController?.popViewController(animated: false)
    }

    private func completeCrop() {
        cropViewController.commitCurrentCrop()
    }

    // MARK: - Actions

    override func setAddTarget() {
        rootView.topNavigationBar.backButtonAction = { [weak self] in
            self?.popViewController()
        }

        rootView.topNavigationBar.rightButtonAction = { [weak self] in
            self?.completeCrop()
        }
    }
}

// MARK: - CropViewControllerDelegate

extension ProfileImageCropViewController: CropViewControllerDelegate {
    func cropViewController(
        _ cropViewController: CropViewController,
        didCropToImage image: UIImage,
        withRect cropRect: CGRect,
        angle: Int
    ) {
        onCropCompleted?(image)
        popViewController()
    }

    func cropViewController(
        _ cropViewController: CropViewController,
        didFinishCancelled cancelled: Bool
    ) {
        popViewController()
    }
}
