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
    
    private func navigateToProfileChangeViewController() {
        let profileChangeViewController = ProfileChangeViewController()
        profileChangeViewController.hidesBottomBarWhenPushed = true
        navigationController?.pushViewController(profileChangeViewController, animated: true)
    }

    private func navigateToWithdrawViewController() {
        let withdrawViewController = WithdrawViewController()
        withdrawViewController.hidesBottomBarWhenPushed = true
        navigationController?.pushViewController(withdrawViewController, animated: true)
    }

    private func navigateToContactViewController() {
        let contactViewController = ContactViewController()
        contactViewController.hidesBottomBarWhenPushed = true
        navigationController?.pushViewController(contactViewController, animated: true)
    }

    private func presentLogoutModal() {
        let logoutAction: () -> Void = { [weak self] in
            self?.logout()
        }

        let modal = ActionPrimaryModal(
            title: "로그아웃하시겠습니까?",
            leftButtonTitle: "취소",
            rightButtonTitle: "확인",
            rightButtonAction: logoutAction
        )

        present(modal, animated: true)
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
        rootView.profileChangeButtonAction = { [weak self] in
            self?.navigateToProfileChangeViewController()
        }

        rootView.instagramButtonAction = {
            SettingActionHelper.openInstagram()
        }

        rootView.contactButtonAction = { [weak self] in
            self?.navigateToContactViewController()
        }
        
        rootView.logoutButtonAction = { [weak self] in
            self?.presentLogoutModal()
        }
        
        rootView.withdrawButtonAction = { [weak self] in
            self?.navigateToWithdrawViewController()
        }
    }
}
