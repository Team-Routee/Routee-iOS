//
//  NicknameSettingViewController.swift
//  Routee-iOS
//
//  Created by LEESANGYUP on 7/6/26.
//

import UIKit

final class NicknameSettingViewController: BaseUIViewController {
    let nicknameSettingView = NicknameSettingView()
    
    override func loadView() {
        view = nicknameSettingView
    }
    
    override func setAddTarget() {
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(didTapEmptyArea))
        tapGesture.cancelsTouchesInView = false
        view.addGestureRecognizer(tapGesture)
    }
    
    @objc
    private func didTapEmptyArea() {
        view.endEditing(true)
    }
}
