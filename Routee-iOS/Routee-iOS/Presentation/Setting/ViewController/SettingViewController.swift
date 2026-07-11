//
//  SettingViewController.swift
//  Routee-iOS
//
//  Created by 김세령 on 7/11/26.
//

import UIKit

final class SettingViewController: BaseUIViewController {
    
    // MARK: - UI Properties
    
    private let rootView = SettingView()
    
    // MARK: - Life Cycle
    
    override func loadView() {
        view = rootView
    }
    
    // MARK: - Private Methods
    
    private func openInstagram() {
        guard let url = URL(string: "https://www.instagram.com/") else { return }
        UIApplication.shared.open(url)
    }
    
    private func logout() {
        // TODO: - 로그아웃 API 및 화면 전환 연결
    }
    
    // MARK: - Actions
    
    override func setAddTarget() {
        rootView.instagramButtonAction = { [weak self] in
            self?.openInstagram()
        }
        
        rootView.logoutButtonAction = { [weak self] in
            self?.logout()
        }
    }
}
