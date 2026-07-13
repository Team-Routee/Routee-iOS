//
//  LoginViewController.swift
//  Routee-iOS
//
//  Created by LEESANGYUP on 6/30/26.
//

import AuthenticationServices
import UIKit

protocol LoginViewControllerDelegate: AnyObject {
    func bindToken(_ idToken: String)
}

final class LoginViewController: BaseUIViewController {
    let rootView = LoginView()
    weak var delegate: LoginViewControllerDelegate?
    
    override func loadView() {
        view = rootView
    }
    
    override func setAddTarget() {
        rootView.signInButton.addTarget(self,
                                        action: #selector(didTapSignIn),
                                        for: .touchUpInside
        )
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

extension LoginViewController: ASAuthorizationControllerPresentationContextProviding {
    // 인증창을 보여주기 위한 메서드 (인증창을 보여 줄 화면을 설정
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
            print("idToken: \(identityToken)")
            
            let onboardingViewController = OnboardingViewController()
            delegate = onboardingViewController
            delegate?.bindToken(identityToken)
            onboardingViewController.modalPresentationStyle = .fullScreen
            present(onboardingViewController, animated: true)
            
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
