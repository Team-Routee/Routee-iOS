//
//  WorkoutPhotoLocationViewController.swift
//  Routee-iOS
//
//  Created by LEESANGYUP on 7/12/26.
//

import UIKit

final class WorkoutPhotoLocationViewController: BaseUIViewController {

    var onComplete: ((String?) -> Void)?

    private let rootView: WorkoutPhotoLocationView

    init(image: UIImage) {
        rootView = WorkoutPhotoLocationView(image: image)
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func loadView() {
        view = rootView
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        (tabBarController as? TabBarViewController)?.setCustomTabBarHidden(true)
    }

    override func setAddTarget() {
        rootView.topNavigationBar.backButtonAction = { [weak self] in
            self?.navigationController?.popViewController(animated: true)
        }

        rootView.completeButton.addTarget(
            self,
            action: #selector(didTapCompleteButton),
            for: .touchUpInside
        )
    }

    @objc
    private func didTapCompleteButton() {
        let address = rootView.locationTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines)
        onComplete?(address?.isEmpty == true ? nil : address)
        navigationController?.popViewController(animated: true)
    }
}
