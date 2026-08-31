//
//  PhotoDownloadButton.swift
//  Routee-iOS
//
//  Created by 초긍정행운의포춘쿠키 on 8/19/26.
//

import Photos
import UIKit

import SnapKit
import Then

final class PhotoDownloadButton: BaseUIView {
    
    // MARK: - UI Properties
    
    private let downloadButton = UIButton()

    // MARK: - Properties

    private var imageProvider: (() -> UIImage?)?
    private var showToast: ((String) -> Void)?
     
    // MARK: - Initializer
    
    init() {
        super.init(frame: .zero)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - UI Setting
    
    override func setStyle() {
        backgroundColor = .black80
        layer.cornerRadius = .r8
        layer.masksToBounds = true
        
        downloadButton.do {
            $0.setImage(.icDownload, for: .normal)
            $0.imageView?.contentMode = .scaleAspectFit
        }
    }
    
    override func setUI() {
        addSubview(downloadButton)

        setActions()
    }
    
    override func setLayout() {
        snp.makeConstraints {
            $0.size.equalTo(40)
        }
        
        downloadButton.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
    }

    // MARK: - Public Methods

    func configure(
        imageProvider: @escaping () -> UIImage?,
        showToast: @escaping (String) -> Void
    ) {
        self.imageProvider = imageProvider
        self.showToast = showToast
    }

    private func setActions() {
        downloadButton.addAction(UIAction { [weak self] _ in
            self?.saveImageToPhotoLibrary()
        }, for: .touchUpInside)
    }

    // MARK: - Private Methods

    private func saveImageToPhotoLibrary() {
        guard let image = imageProvider?() else {
            showToast?(ToastMessage.failedToDownload)
            return
        }

        downloadButton.isUserInteractionEnabled = false

        PHPhotoLibrary.requestAuthorization(for: .addOnly) { [weak self] status in
            guard let self else { return }

            guard status == .authorized || status == .limited else {
                DispatchQueue.main.async {
                    self.handleAuthorizationFailure()
                }
                return
            }

            PHPhotoLibrary.shared().performChanges {
                PHAssetChangeRequest.creationRequestForAsset(from: image)
            } completionHandler: { success, _ in
                DispatchQueue.main.async {
                    if success {
                        self.handleSaveSuccess()
                    } else {
                        self.handleSaveFailure()
                    }
                }
            }
        }
    }

    private func handleSaveSuccess() {
        showToast?(ToastMessage.successToDownload)
        downloadButton.isUserInteractionEnabled = false
        downloadButton.setImage(.icSuccessWhite, for: .normal)

        DispatchQueue.main.asyncAfter(deadline: .now() + 2) { [weak self] in
            guard let self else { return }

            downloadButton.setImage(.icDownload, for: .normal)
            downloadButton.isUserInteractionEnabled = true
        }
    }

    private func handleSaveFailure() {
        showToast?(ToastMessage.failedToDownload)
        enableButtonAfterToast()
    }

    private func handleAuthorizationFailure() {
        showToast?(ToastMessage.noPhotoPermission)
        enableButtonAfterToast()
    }

    private func enableButtonAfterToast() {
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) { [weak self] in
            guard let self else { return }

            downloadButton.isUserInteractionEnabled = true
        }
    }
}
