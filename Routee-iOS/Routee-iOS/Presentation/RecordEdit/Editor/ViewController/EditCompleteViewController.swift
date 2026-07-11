//
//  EditCompleteViewController.swift
//  Routee-iOS
//
//  Created by 김세령 on 7/11/26.
//

import UIKit

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
    
    // MARK: - Actions
    
    override func setAddTarget() {
        rootView.topNavigationBar.backButtonAction = { [weak self] in
            self?.popViewController()
        }
        
        rootView.topNavigationBar.rightButtonAction = { [weak self] in
            self?.popViewController()
        }
    }
}
