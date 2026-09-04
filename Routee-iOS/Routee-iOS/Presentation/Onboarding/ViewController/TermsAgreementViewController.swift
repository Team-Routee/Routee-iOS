//
//  TermsAgreementViewController.swift
//  Routee-iOS
//
//  Created by LEESANGYUP on 8/26/26.
//

import SafariServices
import UIKit

struct TermsAgreementURLs {
    let serviceTerms: URL
    let privacyPolicy: URL
    let locationTerms: URL

    static var routee: Self {
        guard
            let serviceTerms = URL(
                string: "https://app.notion.com/p/395999c4e13b80f088a3c6ff365b0177?source=copy_link"
            ),
            let privacyPolicy = URL(
                string: "https://app.notion.com/p/395999c4e13b80e38b45c4fe81688642?source=copy_link"
            ),
            let locationTerms = URL(
                string: "https://app.notion.com/p/395999c4e13b80ebb999d285fdfaaffd?source=copy_link"
            )
        else {
            preconditionFailure("약관 URL 생성에 실패했습니다.")
        }

        return Self(
            serviceTerms: serviceTerms,
            privacyPolicy: privacyPolicy,
            locationTerms: locationTerms
        )
    }
}

final class TermsAgreementViewController: BaseUIViewController {
    private let identityToken: String
    private let appleUserID: String
    private let termsURLs: TermsAgreementURLs
    private let termsAgreementView = TermsAgreementView()

    init(
        identityToken: String,
        appleUserID: String,
        termsURLs: TermsAgreementURLs = .routee
    ) {
        self.identityToken = identityToken
        self.appleUserID = appleUserID
        self.termsURLs = termsURLs

        super.init(nibName: nil, bundle: nil)
    }

    @MainActor
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Life Cycle

    override func loadView() {
        view = termsAgreementView
    }

    // MARK: - Add Targets

    override func setAddTarget() {
        termsAgreementView.backButtonAction = { [weak self] in
            self?.navigationController?.popViewController(animated: true)
        }

        termsAgreementView.nextButton.addTarget(
            self,
            action: #selector(didTapNextButton),
            for: .touchUpInside
        )

        termsAgreementView.serviceTermsButton.setChevronAction(
            target: self,
            action: #selector(didTapServiceTerms)
        )

        termsAgreementView.privacyPolicyButton.setChevronAction(
            target: self,
            action: #selector(didTapPrivacyPolicy)
        )

        termsAgreementView.locationTermsButton.setChevronAction(
            target: self,
            action: #selector(didTapLocationTerms)
        )
    }

    // MARK: - Actions

    @objc
    private func didTapNextButton() {
        guard termsAgreementView.hasAgreedToRequiredTerms else { return }

        let viewController = OnboardingViewController(
            identityToken: identityToken,
            appleUserID: appleUserID,
            agreements: termsAgreementView.agreements
        )
        navigationController?.setViewControllers([viewController], animated: true)
    }

    @objc
    private func didTapServiceTerms() {
        presentTermsPage(url: termsURLs.serviceTerms)
    }

    @objc
    private func didTapPrivacyPolicy() {
        presentTermsPage(url: termsURLs.privacyPolicy)
    }

    @objc
    private func didTapLocationTerms() {
        presentTermsPage(url: termsURLs.locationTerms)
    }

    private func presentTermsPage(url: URL) {
        let safariViewController = SFSafariViewController(url: url)
        safariViewController.dismissButtonStyle = .close
        safariViewController.preferredControlTintColor = .brandPrimary
        present(safariViewController, animated: true)
    }
}
