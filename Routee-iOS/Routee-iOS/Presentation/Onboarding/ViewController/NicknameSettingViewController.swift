//
//  NicknameSettingViewController.swift
//  Routee-iOS
//
//  Created by LEESANGYUP on 7/6/26.
//

import UIKit

final class NicknameSettingViewController: BaseUIViewController {
    let nicknameSettingView = NicknameSettingView()
    
    // MARK: - Life Cycle
    
    override func loadView() {
        view = nicknameSettingView
    }
    
    // MARK: - Add Targets
    
    override func setAddTarget() {
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(didTapKeyboardHide))
        tapGesture.cancelsTouchesInView = false
        view.addGestureRecognizer(tapGesture)
    }
        
    // MARK: - Actions

    @objc
    private func didTapKeyboardHide() {
        view.endEditing(true)
    }
}
