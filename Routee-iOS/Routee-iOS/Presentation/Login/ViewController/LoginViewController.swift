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
    private var shouldShowSignUpCompletionModal: Bool

    init(showSignUpCompletionModal: Bool = false) {
        self.shouldShowSignUpCompletionModal = showSignUpCompletionModal
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func loadView() {
        view = rootView
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        guard shouldShowSignUpCompletionModal else { return }
        shouldShowSignUpCompletionModal = false
        presentSignUpCompletionModal()
    }
    
    // MARK: - Private Methods

    private func presentSignUpCompletionModal() {
        let modal = ActionPrimaryModal(
            title: "Welcome to Routee!",
            description: "회원가입이 완료되었습니다.",
            actionCount: .single,
            leftButtonTitle: "확인"
        )

        present(modal, animated: true)
    }
    
    private func login(identityToken: String, authorizationCode: String, appleUserID: String) {
        Task { [weak self] in
            guard let self else { return }

            do {
                try await viewModel.login(
                    platform: .APPLE,
                    identityToken: identityToken,
                    authorizationCode: authorizationCode,
                    appleUserID: appleUserID
                )
                await MainActor.run {
                    self.goToMainService()
                }
            } catch RouteeError.notFound {
                await MainActor.run {
                    self.goToRegister(identityToken: identityToken)
                }
            } catch {
                RouteeLogger.error(error)
            }
        }
    }

    private func goToRegister(identityToken: String) {
        let viewController = TermsAgreementViewController(identityToken: identityToken)
        navigationController?.pushViewController(viewController, animated: true)
    }
    
    private func goToMainService() {
        guard let window = view.window else { return }
        window.rootViewController = TabBarViewController()
    }
    
    // MARK: - Actions
    
    override func setAddTarget() {
        rootView.signInButton.addTarget(self, action: #selector(didTapSignIn), for: .touchUpInside)
        rootView.serviceTermsTapAction = {
            ExternalURLHandler.openTermsOfService()
        }
        rootView.privacyPolicyTapAction = {
            ExternalURLHandler.openPrivacyPolicy()
        }
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
            
            guard
                let identityTokenData = appleIdCredential.identityToken,
                let identityToken = String(data: identityTokenData, encoding: .utf8),
                let authorizationCodeData = appleIdCredential.authorizationCode,
                let authorizationCode = String(data: authorizationCodeData, encoding: .utf8),
                !authorizationCode.isEmpty
            else {
                print("Token 변환 실패")
                return
            }
            
            
            login(
                identityToken: identityToken,
                authorizationCode: authorizationCode,
                appleUserID: userIdentifier
            )
            
        case is ASPasswordCredential:
            let mainVC = SampleViewController()
            mainVC.modalPresentationStyle = .fullScreen
            present(mainVC, animated: true)
            
        default: break
        }
    }
}
