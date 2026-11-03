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
                string: "https://acoustic-boat-573.notion.site/3d57d9beca1d8037bafdfb57414e9c65"
            ),
            let privacyPolicy = URL(
                string: "https://acoustic-boat-573.notion.site/3d57d9beca1d800cbacdf28bf6006257"
            ),
            let locationTerms = URL(
                string: "https://acoustic-boat-573.notion.site/3d57d9beca1d80e1b6d4e7e4750b94e6"
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
    private let termsURLs: TermsAgreementURLs
    private let termsAgreementView = TermsAgreementView()

    init(
        identityToken: String,
        termsURLs: TermsAgreementURLs = .routee
    ) {
        self.identityToken = identityToken
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
