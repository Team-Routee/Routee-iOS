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
    
    private let editedImage: UIImage
    
    // MARK: - UI Properties
    
    private let rootView = EditCompleteView()
    
    // MARK: - Initializer
    
    init(editedImage: UIImage) {
        self.editedImage = editedImage
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
        
        rootView.updateImage(editedImage)
    }
    
    // MARK: - Private Methods
    
    private func popViewController() {
        navigationController?.popViewController(animated: false)
    }
    
    private func saveImageToPhotoLibrary() {
        PHPhotoLibrary.requestAuthorization(for: .addOnly) { [weak self] status in
            guard let self else { return }

            guard status == .authorized || status == .limited else {
                DispatchQueue.main.async {
                    self.view.showToast(title: "사진 접근 권한이 필요해요")
                }
                return
            }

            PHPhotoLibrary.shared().performChanges {
                PHAssetChangeRequest.creationRequestForAsset(from: self.editedImage)
            } completionHandler: { success, _ in
                DispatchQueue.main.async {
                    if success {
                        self.view.showToast(title: "갤러리에 저장되었습니다.")
                    } else {
                        self.view.showToast(title: "갤러리 저장에 실패했습니다.")
                    }
                }
            }
        }
    }
    
    private func exportImage() {
        let activityViewController = UIActivityViewController(
            activityItems: [editedImage],
            applicationActivities: nil
        )

        present(activityViewController, animated: true)
    }
    
    // MARK: - Actions
    
    override func setAddTarget() {
        rootView.topNavigationBar.backButtonAction = { [weak self] in
            self?.popViewController()
        }
        
        rootView.topNavigationBar.rightButtonAction = { [weak self] in
            self?.popViewController()
        }
        
        rootView.setDownloadButtonAction { [weak self] in
            self?.saveImageToPhotoLibrary()
        }
        
        rootView.setExportButtonAction { [weak self] in
            self?.exportImage()
        }
    }
}
