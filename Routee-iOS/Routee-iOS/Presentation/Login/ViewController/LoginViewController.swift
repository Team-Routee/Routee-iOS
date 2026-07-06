//
//  LoginViewController.swift
//  Routee-iOS
//
//  Created by LEESANGYUP on 6/30/26.
//

import AuthenticationServices
import UIKit

final class LoginViewController: BaseUIViewController {
    let rootView = LoginView()
    
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
        
        // 사용자에게 제공받을 정보를 선택 (이름 및 이메일)
        reuqeuest.requestedScopes = [.fullName]
        
        let controller = ASAuthorizationController(authorizationRequests: [reuqeuest])
        
        // 로그인 정보 관련 대리자 설정
        controller.delegate = self
        
        // 인증창을 보여주기 위해 대리자 설정
        controller.presentationContextProvider = self
        
        // 요청
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
    
    // 로그인 실패 시
    func authorizationController(controller: ASAuthorizationController,
                                 didCompleteWithError error: any Error
    ) {
        print("로그인 실패", error.localizedDescription)
    }
    
    // Apple ID 로그인에 성공한 경우, 사용자의 인증 정보를 확인하고 필요한 작업을 수행합니다
    func authorizationController(controller: ASAuthorizationController,
                                 didCompleteWithAuthorization authorization: ASAuthorization) {
        switch authorization.credential {
        case let appleIdCredential as ASAuthorizationAppleIDCredential:
            let userIdentifier = appleIdCredential.user
            let fullName = appleIdCredential.fullName
            let email = appleIdCredential.email
            
            guard
                let identityTokenData = appleIdCredential.identityToken,
                let identityToken = String(data: identityTokenData, encoding: .utf8),
                
                let authorizationCodeData = appleIdCredential.authorizationCode,
                let authorizationCode = String(
                    data: authorizationCodeData,
                    encoding: .utf8
                )
            else {
                print("Token 변환 실패")
                return
            }
            
            let userName = [fullName?.familyName, fullName?.givenName]
                .compactMap { $0 }
                .joined()
            
            let loginModel = LoginModel(
                identityToken: identityToken,
                appleUserIdentifier: userIdentifier,
                userName: userName.isEmpty ? nil : userName
            )
            
            print("Apple ID 로그인에 성공하였습니다.")
            print("사용자 ID: \(userIdentifier)")
            print("전체 이름: \(fullName?.givenName ?? "") \(fullName?.familyName ?? "")")
            print("이메일: \(email ?? "")")
            print("Token: \(identityToken)")
            print("authorizationCode: \(authorizationCode)")
            
            // 여기에 로그인 성공 후 수행할 작업을 추가하세요.
            let mainVC = SampleViewController()
            mainVC.modalPresentationStyle = .fullScreen
            present(mainVC, animated: true)
            
            // 암호 기반 인증에 성공한 경우(iCloud), 사용자의 인증 정보를 확인하고 필요한 작업을 수행합니다
        case let passwordCredential as ASPasswordCredential:
            let userIdentifier = passwordCredential.user
            let password = passwordCredential.password
            
            print("암호 기반 인증에 성공하였습니다.")
            print("사용자 이름: \(userIdentifier)")
            print("비밀번호: \(password)")
            
            // 여기에 로그인 성공 후 수행할 작업을 추가하세요.
            let mainVC = SampleViewController()
            mainVC.modalPresentationStyle = .fullScreen
            present(mainVC, animated: true)
            
        default: break
            
        }
    }
}
