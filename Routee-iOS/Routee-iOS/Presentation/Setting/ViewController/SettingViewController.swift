//
//  SettingViewController.swift
//  Routee-iOS
//
//  Created by 김세령 on 7/11/26.
//

import UIKit

final class SettingViewController: BaseUIViewController {
    
    // MARK: - Properties
    
    private let viewModel = SettingViewModel()
    private let keychain = DefaultKeychainService()
    
    // MARK: - UI Properties
    
    private let rootView = SettingView()
    
    // MARK: - Life Cycle
    
    override func loadView() {
        view = rootView
    }
    
    // MARK: - Private Methods
    
    private func openInstagram() {
        guard let url = URL(string: "https://www.instagram.com/routee_official/?hl=ko") else { return }
        UIApplication.shared.open(url)
    }
    
    private func didTapPrivacyButton() {
        let refreshToken = keychain.read(.refreshToken)
        
        Task {
            do {
                try await viewModel.withdraw(refreshToken: refreshToken)
            } catch {
                print("회원 탈퇴 실패", error)
            }
        }
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
        
        rootView.policyButtonAction = { [self] in
            didTapPrivacyButton()
        }
    }
}
