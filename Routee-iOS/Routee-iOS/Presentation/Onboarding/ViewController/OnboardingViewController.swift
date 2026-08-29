//
//  OnboardingViewController.swift
//  Routee-iOS
//
//  Created by LEESANGYUP on 7/6/26.
//

import UIKit

final class OnboardingViewController: BaseUIViewController {
    private var identityToken: String?
    private var appleUserID: String?

    init(identityToken: String?, appleUserID: String?) {
        self.identityToken = identityToken
        self.appleUserID = appleUserID

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
        guard let identityToken, let appleUserID else {
            print("idToken이 없습니다.")
            return
        }
        let nickname = nicknameSettingView.nickname.trimmingCharacters(in: .whitespacesAndNewlines)
        
        guard nicknameSettingView.isNicknameValid, !nickname.isEmpty else {
            return
        }
        
        Task {
            do {
                try await viewModel.registerAndLogin(
                    platform: .APPLE,
                    identityToken: identityToken,
                    appleUserID: appleUserID,
                    nickname: nickname
                )

                await MainActor.run {
                    let viewController = TabBarViewController()
                    viewController.modalPresentationStyle = .fullScreen
                    present(viewController, animated: true)
                }
            } catch {
                print("서버 로그인 실패", error)
            }
        }
    }
}
