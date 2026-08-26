//
//  ContactView.swift
//  Routee-iOS
//
//  Created by 초긍정행운의포춘쿠키 on 8/26/26.
//

import UIKit

final class WithdrawViewController: BaseUIViewController {

    // MARK: - Properties

    private let viewModel = SettingViewModel()

    // MARK: - UI Properties

    private let rootView = WithdrawView()

    // MARK: - Life Cycle

    override func loadView() {
        view = rootView
    }

    // MARK: - Private Methods

    private func withdraw() {
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
                RouteeLogger.error(error)
            }
        }
    }

    // MARK: - Actions

    override func setAddTarget() {
        rootView.backButtonAction = { [weak self] in
            self?.navigationController?.popViewController(animated: true)
        }

        rootView.withdrawButtonAction = { [weak self] in
            self?.withdraw()
        }

        rootView.kakaoButtonAction = {
            SettingActionHelper.openKakaoChannel()
        }

        rootView.emailButtonAction = { [weak self] in
            SettingActionHelper.copyEmail()
            self?.rootView.showToast(title: SettingActionHelper.emailCopiedToastMessage)
        }
    }
}
