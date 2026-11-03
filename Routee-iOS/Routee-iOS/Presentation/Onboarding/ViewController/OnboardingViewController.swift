//
//  OnboardingViewController.swift
//  Routee-iOS
//
//  Created by LEESANGYUP on 7/6/26.
//

import UIKit

final class OnboardingViewController: BaseUIViewController {
    private let identityToken: String?
    private let agreements: RegisterInfoModel.Agreements

    init(
        identityToken: String?,
        agreements: RegisterInfoModel.Agreements
    ) {
        self.identityToken = identityToken
        self.agreements = agreements

        super.init(nibName: nil, bundle: nil)
    }
    
    @MainActor
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    let viewModel = OnboardingViewModel()
    let nicknameSettingView = OnboardingView()
    
    // MARK: - Life Cycle
    
    override func loadView() {
        view = nicknameSettingView
    }
    
    // MARK: - Add Targets
    
    override func setAddTarget() {
        nicknameSettingView.startButton.addTarget(
            self,
            action: #selector(didTapStartButton),
            for: .touchUpInside
        )
    }
        
    // MARK: - Actions

    @objc
    private func didTapStartButton() {
        guard let identityToken else {
            RouteeLogger.error(RouteeError.noData)
            return
        }
        let nickname = nicknameSettingView.nickname.trimmingCharacters(in: .whitespacesAndNewlines)

        guard nicknameSettingView.isNicknameValid, !nickname.isEmpty else {
            return
        }

        Task {
            do {
                try await viewModel.register(
                    registerInfo: RegisterInfoModel(
                        nickname: nickname,
                        identityToken: identityToken,
                        provider: .APPLE,
                        agreements: agreements
                    )
                )

                await MainActor.run {
                    NotificationCenter.default.post(
                        name: .signUpCompleted,
                        object: nil
                    )
                }
            } catch {
                RouteeLogger.error(error)
            }
        }
    }
}
