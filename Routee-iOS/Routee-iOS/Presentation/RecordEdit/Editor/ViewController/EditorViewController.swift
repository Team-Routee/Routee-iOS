//
//  EditorViewController.swift
//  Routee-iOS
//
//  Created by 김세령 on 7/8/26.
//

import UIKit

import SnapKit
import Then

final class EditorViewController: BaseUIViewController {
    
    // MARK: - UI Properties
    
    private let rootView = EditorView()
    
    // MARK: - Life Cycle
    
    override func loadView() {
        view = rootView
    }

    // MARK: - Private Methods

    private func popViewController() {
        UIView.performWithoutAnimation {
            navigationController?.popViewController(animated: false)
        }
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
