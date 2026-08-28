//
//  ContactView.swift
//  Routee-iOS
//
//  Created by 초긍정행운의포춘쿠키 on 8/26/26.
//
import UIKit

final class ContactViewController: BaseUIViewController {

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

        rootView.kakaoButtonAction = {
            ExternalURLHandler.openKakaoChannel()
        }

        rootView.emailButtonAction = { [weak self] in
            guard let self else { return }

            ClipboardHelper.copy(ClipboardHelper.routeeEmail)
            rootView.showToast(title: ToastMessage.emailCopied)
        }
    }
}
