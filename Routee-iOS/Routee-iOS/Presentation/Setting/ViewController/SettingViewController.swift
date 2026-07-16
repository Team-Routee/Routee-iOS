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
        Task {
            do {
                try await viewModel.withdraw()
                
                await MainActor.run {
                    NotificationCenter.default.post(
                        name: .navigateLoginViewController,
                        object: nil
                    )
                }
            } catch {
                print("회원 탈퇴 실패", error)
            }
        }
    }
    
    private func logout() {
        Task {
            do {
                try await viewModel.logout()

                await MainActor.run {
                    NotificationCenter.default.post(
                        name: .navigateLoginViewController,
                        object: nil
                    )
                }
            } catch {
                RouteeLogger.error(error)
            }
        }
    }
    
    // MARK: - Actions
    
    override func setAddTarget() {
        rootView.instagramButtonAction = { [weak self] in
            self?.openInstagram()
        }
        
        rootView.logoutButtonAction = { [weak self] in
            self?.logout()
        }
        
        rootView.policyButtonAction = { [weak self] in
            self?.didTapPrivacyButton()
        }
    }
}
