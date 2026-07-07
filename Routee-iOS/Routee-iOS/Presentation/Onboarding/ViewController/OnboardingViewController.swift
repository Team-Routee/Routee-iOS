//
//  OnboardingViewController.swift
//  Routee-iOS
//
//  Created by LEESANGYUP on 7/6/26.
//

import UIKit

final class OnboardingViewController: BaseUIViewController {
    private var identityToken: String?
    
    let viewModel = OnboardingViewModel()
    let nicknameSettingView = OnboardingView()
    
    // MARK: - Life Cycle
    
    override func loadView() {
        view = nicknameSettingView
    }
    
    // MARK: - Add Targets
    
    override func setAddTarget() {
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(didTapKeyboardHide))
        tapGesture.cancelsTouchesInView = false
        view.addGestureRecognizer(tapGesture)
        
        nicknameSettingView.startButton.addTarget(
            self,
            action: #selector(didTapStartButton),
            for: .touchUpInside
        )
    }
        
    // MARK: - Actions

    @objc
    private func didTapKeyboardHide() {
        view.endEditing(true)
    }
    
    @objc
    private func didTapStartButton() {
        guard let identityToken else {
            print("idToken이 없습니다.")
            return
        }
        let nickname = nicknameSettingView.nickname.trimmingCharacters(in: .whitespacesAndNewlines)
        
        guard !nickname.isEmpty else {
            print("닉네임을 입력해주세요.")
            return
        }
        
        Task {
            do {
                try await viewModel.appleLogin(
                    platform: .APPLE,
                    identityToken: identityToken,
                    nickname: nickname
                )

                await MainActor.run {
                    let mainVC = SampleViewController()
                    mainVC.modalPresentationStyle = .fullScreen
                    present(mainVC, animated: true)
                }
            } catch {
                print("서버 로그인 실패", error)
            }
        }
    }
}

extension OnboardingViewController: LoginViewControllerDelegate {
    func bindToken(_ idToken: String) {
        identityToken = idToken
    }
}
