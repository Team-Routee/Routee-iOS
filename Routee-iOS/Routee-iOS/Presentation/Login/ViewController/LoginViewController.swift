//
//  LoginViewController.swift
//  Routee-iOS
//
//  Created by LEESANGYUP on 6/30/26.
//

import AuthenticationServices
import UIKit

final class LoginViewController: BaseUIViewController {
    
    // MARK: - Properties
    
    private let viewModel = LoginViewModel()
    private let rootView = LoginView()
    
    override func loadView() {
        view = rootView
    }
    
    // MARK: - Private Methods
    
    private func login(identityToken: String, appleUserID: String) {
        Task { [weak self] in
            guard let self else { return }

            do {
                try await viewModel.login(
                    platform: .APPLE,
                    identityToken: identityToken,
                    appleUserID: appleUserID
                )
                await MainActor.run {
                    self.goToMainService()
                }
            } catch RouteeError.notFound {
                await MainActor.run {
                    self.goToRegister(
                        identityToken: identityToken,
                        appleUserID: appleUserID
                    )
                }
            } catch {
                RouteeLogger.error(error)
            }
        }
    }

    private func goToRegister(identityToken: String, appleUserID: String) {
        let viewController = OnboardingViewController(
            identityToken: identityToken,
            appleUserID: appleUserID
        )
        navigationController?.setViewControllers([viewController], animated: true)
    }
    
    private func goToMainService() {
        guard let window = view.window else { return }
        window.rootViewController = TabBarViewController()
    }
    
    // MARK: - Actions
    
    override func setAddTarget() {
        rootView.signInButton.addTarget(self, action: #selector(didTapSignIn), for: .touchUpInside)
    }
    
    @objc
    func didTapSignIn() {
        let provider = ASAuthorizationAppleIDProvider()
        let reuqeuest = provider.createRequest()
        reuqeuest.requestedScopes = [.fullName]
        
        let controller = ASAuthorizationController(authorizationRequests: [reuqeuest])
        controller.delegate = self
        controller.presentationContextProvider = self
        controller.performRequests()
    }
}

// MARK: - Extension

extension LoginViewController: ASAuthorizationControllerPresentationContextProviding {
    func presentationAnchor(for controller: ASAuthorizationController) -> ASPresentationAnchor {
        self.view.window ?? UIWindow()
    }
}

extension LoginViewController: ASAuthorizationControllerDelegate {
    
    func authorizationController(controller: ASAuthorizationController,
                                 didCompleteWithError error: any Error
    ) {
        print("로그인 실패", error.localizedDescription)
    }
    
    func authorizationController(controller: ASAuthorizationController,
                                 didCompleteWithAuthorization authorization: ASAuthorization) {
        switch authorization.credential {
        case let appleIdCredential as ASAuthorizationAppleIDCredential:
            let userIdentifier = appleIdCredential.user
            let fullName = appleIdCredential.fullName
            let email = appleIdCredential.email
            
            guard
                let identityTokenData = appleIdCredential.identityToken,
                let identityToken = String(data: identityTokenData, encoding: .utf8)
            else {
                print("Token 변환 실패")
                return
            }
            
            print("Apple ID 로그인에 성공하였습니다.")
            print("사용자 ID: \(userIdentifier)")
            print("전체 이름: \(fullName?.givenName ?? "") \(fullName?.familyName ?? "")")
            print("이메일: \(email ?? "")")
            
            login(identityToken: identityToken, appleUserID: userIdentifier)
            
        case let passwordCredential as ASPasswordCredential:
            let userIdentifier = passwordCredential.user
            let password = passwordCredential.password
            
            print("암호 기반 인증에 성공하였습니다.")
            print("사용자 이름: \(userIdentifier)")
            print("비밀번호: \(password)")
            
            let mainVC = SampleViewController()
            mainVC.modalPresentationStyle = .fullScreen
            present(mainVC, animated: true)
            
        default: break
        }
    }
}
