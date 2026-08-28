//
//  EditCompleteViewController.swift
//  Routee-iOS
//
//  Created by 김세령 on 7/11/26.
//

import UIKit

import Photos

final class EditCompleteViewController: BaseUIViewController {

    // MARK: - Properties
    
    private enum WatermarkLayout {
        static let designWidth: CGFloat = 343
        static let leadingOffset: CGFloat = 249
        static let bottomOffset: CGFloat = 20
        static let size = CGSize(width: 74, height: 10)
    }
    private let watermarkedImage: UIImage

    // MARK: - UI Properties

    private let rootView = EditCompleteView()

    // MARK: - Initializer

    init(editedImage: UIImage) {
        self.watermarkedImage = Self.makeWatermarkedImage(from: editedImage)
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

        rootView.updateImage(watermarkedImage)
    }

    // MARK: - Private Methods

    private func popViewController() {
        navigationController?.popViewController(animated: false)
    }

    private func navigateToWorkout() {
        guard let tabBarController = tabBarController as? TabBarViewController,
              let viewControllers = tabBarController.viewControllers,
              let workoutNavigationController = viewControllers.first as? UINavigationController
        else {
            navigationController?.popToRootViewController(animated: false)
            return
        }

        navigationController?.popToRootViewController(animated: false)
        workoutNavigationController.popToRootViewController(animated: false)
        tabBarController.selectTab(index: 0)
    }

    private func saveImageToPhotoLibrary() {
        PHPhotoLibrary.requestAuthorization(for: .addOnly) { [weak self] status in
            guard let self else { return }

            guard status == .authorized || status == .limited else {
                DispatchQueue.main.async {
                    self.rootView.showToast(title: "사진 접근 권한이 없습니다. 설정으로 이동하여 권한 설정을 허용해주세요.")
                }
                return
            }

            PHPhotoLibrary.shared().performChanges {
                PHAssetChangeRequest.creationRequestForAsset(from: self.watermarkedImage)
            } completionHandler: { success, _ in
                DispatchQueue.main.async {
                    if success {
                        self.rootView.showToast(title: "갤러리에 저장되었습니다.")
                    } else {
                        self.rootView.showToast(title: "갤러리 저장에 실패했습니다.")
                    }
                }
            }
        }
    }

    private func exportImage() {
        let activityViewController = UIActivityViewController(
            activityItems: [watermarkedImage],
            applicationActivities: nil
        )

        present(activityViewController, animated: true)
    }

    private static func makeWatermarkedImage(from image: UIImage) -> UIImage {
        guard let watermarkImage = UIImage(named: "routee_logo_watermark") else {
            return image
        }

        let watermarkScale = image.size.width / WatermarkLayout.designWidth
        let watermarkSize = CGSize(
            width: WatermarkLayout.size.width * watermarkScale,
            height: WatermarkLayout.size.height * watermarkScale
        )
        let watermarkOrigin = CGPoint(
            x: WatermarkLayout.leadingOffset * watermarkScale,
            y: image.size.height - (WatermarkLayout.bottomOffset * watermarkScale) - watermarkSize.height
        )
        let format = UIGraphicsImageRendererFormat()
        format.scale = image.scale

        return UIGraphicsImageRenderer(size: image.size, format: format).image { _ in
            image.draw(in: CGRect(origin: .zero, size: image.size))
            watermarkImage.draw(in: CGRect(origin: watermarkOrigin, size: watermarkSize))
        }
    }

    // MARK: - Actions

    override func setAddTarget() {
        rootView.topNavigationBar.backButtonAction = { [weak self] in
            self?.popViewController()
        }

        rootView.topNavigationBar.rightButtonAction = { [weak self] in
            self?.navigateToWorkout()
        }

        rootView.setDownloadButtonAction { [weak self] in
            self?.saveImageToPhotoLibrary()
        }

        rootView.setExportButtonAction { [weak self] in
            self?.exportImage()
        }
    }
}
