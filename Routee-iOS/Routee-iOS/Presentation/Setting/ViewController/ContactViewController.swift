//
//  ContactView.swift
//  Routee-iOS
//
//  Created by 초긍정행운의포춘쿠키 on 8/26/26.
//
import UIKit

final class ContactViewController: BaseUIViewController {

    // MARK: - Properties

    private let kakaoChannelURLString = "http://pf.kakao.com/_ExkxgSX"
    private let emailText = "routee.ask@gmail.com"

    // MARK: - UI Properties

    private let rootView = ContactView()

    // MARK: - Life Cycle

    override func loadView() {
        view = rootView
    }

    // MARK: - Actions

    override func setAddTarget() {
        rootView.backButtonAction = { [weak self] in
            self?.navigationController?.popViewController(animated: true)
        }

        rootView.kakaoButtonAction = { [weak self] in
            self?.openKakaoChannel()
        }
    }

    // MARK: - Private Methods

    private func openKakaoChannel() {
        guard let url = URL(string: kakaoChannelURLString) else { return }

        UIApplication.shared.open(url)
    }
}
