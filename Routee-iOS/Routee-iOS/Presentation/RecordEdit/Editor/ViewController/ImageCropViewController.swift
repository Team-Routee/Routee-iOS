//
//  ImageCropViewController.swift
//  Routee-iOS
//
//  Created by 김세령 on 7/10/26.
//

import UIKit

import CropViewController
import TOCropViewController

final class ImageCropViewController: BaseUIViewController {
    
    // MARK: - Properties
    
    var onCropCompleted: ((UIImage) -> Void)?
    private let cropViewController: CropViewController
    
    // MARK: - UI Property
    
    private let rootView = ImageCropView()
    
    // MARK: - Initializer
    
    init(image: UIImage) {
        self.cropViewController = CropViewController(image: image)
        super.init(nibName: nil, bundle: nil)
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
        rootView.setCropContentView(cropViewController.view)
        cropViewController.didMove(toParent: self)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        hideCropDefaultToolbar()
        cropViewController.hidesNavigationBar = false
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        hideCropDefaultToolbar()
        DispatchQueue.main.async { [weak self] in
            self?.hideCropDefaultToolbar()
        }
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        hideCropDefaultToolbar()
    }
    
    // MARK: - Private Methods
    
    private func setCropViewController() {
        cropViewController.delegate = self
        cropViewController.aspectRatioPreset = CGSize(width: 343, height: 610)
        cropViewController.aspectRatioLockEnabled = true
        cropViewController.resetAspectRatioEnabled = false
        hideCropDefaultToolbar()
    }
    
    private func hideCropDefaultToolbar() {
        cropViewController.doneButtonHidden = true
        cropViewController.cancelButtonHidden = true
        cropViewController.toolbar.alpha = 0
        cropViewController.toolbar.isHidden = true
        cropViewController.toolbar.isUserInteractionEnabled = false
        cropViewController.toolbar.doneButtonHidden = true
        cropViewController.toolbar.cancelButtonHidden = true
        
        hideCropDefaultButtons(in: cropViewController.view)
    }
    
    private func hideCropDefaultButtons(in view: UIView) {
        view.subviews.forEach {
            if $0 is UIButton || String(describing: type(of: $0)).contains("Toolbar") {
                $0.alpha = 0
                $0.isHidden = true
                $0.isUserInteractionEnabled = false
            }
            
            hideCropDefaultButtons(in: $0)
        }
    }
    
    private func popViewController() {
        navigationController?.popViewController(animated: false)
    }
    
    private func completeCrop() {
        hideCropDefaultToolbar()
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

extension ImageCropViewController: CropViewControllerDelegate {
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
